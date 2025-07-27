from flask import Blueprint, request, jsonify, make_response
from utils.security import generate_jwt, token_required
from sqlalchemy import func, or_
from db.models import MedicineIngredient, db, SurveyResponse, User, Medicine, Ingredient
from datetime import datetime, timedelta
from openai import OpenAI
import os, random
from dotenv import load_dotenv
import re

survey_bp = Blueprint("survey", __name__, url_prefix="/survey")


load_dotenv()
client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))


@survey_bp.route("/result", methods=['POST'])
@token_required
def result(current_user):
    try:
        user_id = int(current_user["user_id"])  # user_id를 int로 꺼내기
        data = request.json  # 설문 응답 및 수치 데이터
        
        # 주관적 설문
        overall_health_aware = data.get("overall_health_aware")
        daily_function = data.get("daily_function")
        life_pattern = data.get("life_pattern")
        mental = data.get("mental")
        inconvenience_concern = data.get("inconvenience_concern")
        
        subjective_score = data.get("subjective_score")
        
        # 주관적 점수
        subjective_result = {
            "주관적 점수": subjective_score,
            "전반적 건강 인식": overall_health_aware,
            "일상기능&체력": daily_function,
            "생활습관(운동,수면,식사)": life_pattern,
            "정신/감정 상태": mental,
            "질병 관련 불편함 및 불안": inconvenience_concern
        }
        # 객관적 설문
        # 건강검진결과 업로드 했을 경우
        if data.get("upload"):
            objective_result = calculate_objective_score_with_upload(data)
        else:
            objective_result = calculate_objective_score_without_upload(data)
        
        survey_response = SurveyResponse(
            user_id=user_id,
            subjective_responses=subjective_result,
            objective_responses=objective_result,
        )
        db.session.add(survey_response)
        db.session.commit()
        
        
        user = User.query.get(user_id)

        # GPT 프롬프트
        prompt = f"""
        성별: {user.gender}, 나이: {user.dob.year if user.dob else '미상'}, 직업군: {user.occupation}, 근무형태: {user.work_style}
        복용중인 약물: {objective_result['medications']}
        복용중인 영양제: {objective_result['supplements']}
        건강검진 주요 상태: {objective_result['conditions']}

        이 정보를 바탕으로 현재 건강상태를 보완할 수 있는 주요 영양제 성분 2가지 추천해줘
        다른말은 하지 말고 이름만 적어줘
        아래 리스트 중에서만 추천해줘 
        DHA/EPA 제품, 밀크씨슬, 프로바이오틱스, 은행잎 추출물, 홍삼, 비타민 C, 코엔자임 Q10, 멀티비타민, 포스파티딜세린, L-테아닌, 알로에, 홍경천, 녹차추출물, 칼슘 + 비타민D, 글루코사민, 뮤코다당단백, 콘드로이친, 프락토 올리고당, 쏘팔메토 열매추출물, 비타민A, 루테인, 아스타잔틴, 바나바잎
        """
        
        gpt_response = client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[
                {"role": "system", "content": "당신은 영양제 전문가입니다."},
                {"role": "user", "content": prompt}
            ],
            max_tokens=300
        )
        recommendations = gpt_response.choices[0].message.content.strip()
        print("GPT 응답:", recommendations)

        # 쉼표, 줄바꿈 모두 기준으로 나눔
        gpt_ingredients = [item.strip() for item in re.split(r'[,\n]', recommendations) if item.strip()]
        print("추천 성분 리스트:", gpt_ingredients)

        # 디버깅용 검색 개수
        for ing in gpt_ingredients:
            count = db.session.query(Medicine).filter(Medicine.efficacy.ilike(f"%{ing}%")).count()
            print(f"검색 테스트: {ing} -> {count}개")

        supplement_list = get_random_supplements(gpt_ingredients, count=3)


        return jsonify({
            "username": user.name,
            "dob": user.dob,
            "message": "Survey saved successfully",
            "total_score": objective_result,
            "gpt_recommendations": gpt_ingredients,
            "supplement_list": supplement_list  # DB에서 랜덤 추천된 제품 3개
        })

    except Exception as e:
        return jsonify({"message": "Error calculating score", "error": str(e)}), 500
    

def get_random_supplements(ingredient_names, count=3):
    # DB에서 GPT가 추천한 성분 중 실제 존재하는 성분만 검색
    matched_ingredients = (
        db.session.query(Ingredient)
        .filter(Ingredient.name.in_(ingredient_names))
        .all()
    )

    # 성분 ID 리스트
    ingredient_ids = [ing.id for ing in matched_ingredients]

    if not ingredient_ids:
        return {
            "recommended_ingredients": [],
            "supplements": []
        }

    # 추천 성분 중 하나라도 포함된 제품 검색
    query = (
        db.session.query(Medicine)
        .join(MedicineIngredient, Medicine.id == MedicineIngredient.medicine_id)
        .filter(MedicineIngredient.ingredient_id.in_(ingredient_ids))
        .order_by(func.random())
        .limit(count)
    )

    supplements = [
        {
            "name": m.name,
            "manufacturer": m.manufacturer,
            "price": m.price,
            "efficacy": m.efficacy,
            "image_url": m.image_url
        }
        for m in query.all()
    ]

    return {
        "recommended_ingredients": [ing.name for ing in matched_ingredients],
        "supplements": supplements
    }

    
def calculate_objective_score_with_upload(data):
    score = 100
    medications = data.get("medications", [])
    supplements = data.get("supplements", [])
    past_conditions = data.get("past_conditions", [])
    family_history = data.get("family_history", [])

    score -= min(len(medications) * 4, 20)
    score -= min(len(past_conditions) * 2, 10)
    score -= min(len(family_history), 5)

    conditions = {}

    # 5. 혈압
    systolic = data.get("systolic", 0)
    diastolic = data.get("diastolic", 0)
    if systolic > 180 or diastolic > 120:
        score -= 10
        conditions["blood_pressure"] = "위험"
    elif systolic >= 140 or diastolic >= 90:
        score -= 8
        conditions["blood_pressure"] = "위험"
    elif systolic >= 130 or diastolic >= 80:
        score -= 5
        conditions["blood_pressure"] = "위험"
    elif systolic >= 120:
        score -= 3
        conditions["blood_pressure"] = "주의"
    else:
        conditions["blood_pressure"] = "정상"

    # 6. 공복혈당
    fasting_glucose = data.get("fasting_glucose", 0)
    if fasting_glucose >= 126:
        score -= 10
        conditions["fasting_glucose"] = "위험"
    elif fasting_glucose >= 100:
        score -= 5
        conditions["fasting_glucose"] = "주의"
    elif fasting_glucose < 70:
        score -= 12
        conditions["fasting_glucose"] = "위험"
    else:
        conditions["fasting_glucose"] = "정상"

    # 7. BMI
    bmi = data.get("bmi", 0)
    if bmi < 18.5:
        score -= 5
        conditions["bmi"] = "위험"
    elif bmi >= 30:
        score -= 7
        conditions["bmi"] = "위험"
    elif bmi >= 25:
        score -= 5
        conditions["bmi"] = "위험"
    elif bmi >= 24:
        score -= 2
        conditions["bmi"] = "주의"
    else:
        conditions["bmi"] = "정상"

    # 8. AST
    ast = data.get("ast", 0)
    if ast > 100:
        score -= 4
        conditions["ast"] = "위험"
    elif ast >= 61:
        score -= 2
        conditions["ast"] = "위험"
    elif ast >= 41:
        score -= 1
        conditions["ast"] = "주의"
    else:
        conditions["ast"] = "정상"

    # 9. ALT
    alt = data.get("alt", 0)
    if alt > 100:
        score -= 4
        conditions["alt"] = "위험"
    elif alt >= 61:
        score -= 2
        conditions["alt"] = "위험"
    elif alt >= 41:
        score -= 1
        conditions["alt"] = "주의"
    else:
        conditions["alt"] = "정상"

    # 10. eGFR
    egfr = data.get("egfr", 0)
    if egfr < 15:
        score -= 15
        conditions["egfr"] = "위험"
    elif egfr < 30:
        score -= 12
        conditions["egfr"] = "위험"
    elif egfr < 45:
        score -= 9
        conditions["egfr"] = "위험"
    elif egfr < 60:
        score -= 6
        conditions["egfr"] = "주의"
    elif egfr < 90:
        score -= 3
        conditions["egfr"] = "주의"
    else:
        conditions["egfr"] = "정상"

    return {
        "score": score,
        "medications": medications,
        "supplements": supplements,
        "past_conditions": past_conditions,
        "family_history": family_history,
        "conditions": conditions
    }
            
            
# 건강검진결과 업로드 안했을 경우
def calculate_objective_score_without_upload(data):
    score = 35  # 기본 점수 (35점 만점)

    # 1. 약물 복용 체크 (항목당 -4점, 최대 -20점)
    medications = data.get("medications", [])
    score -= min(len(medications) * 4, 20)
    
    # 2. 영양제 복용 체크
    supplements = data.get("supplements", [])

    # 3. 과거 진단 질환 (항목당 -2점, 최대 -10점)
    past_conditions = data.get("past_conditions", [])
    score -= min(len(past_conditions) * 2, 10)

    # 4. 가족력 (항목당 -1점, 최대 -5점)
    family_history = data.get("family_history", [])
    score -= min(len(family_history), 5)
    
    return {
        "score": score / 35 * 100,
        "medications": medications,
        "supplements": supplements,
        "past_conditions": past_conditions,
        "family_history": family_history,
    } 
