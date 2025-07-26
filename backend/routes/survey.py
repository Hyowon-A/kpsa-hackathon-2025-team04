from flask import Blueprint, request, jsonify, make_response
from utils.security import generate_jwt, token_required
from sqlalchemy import select
from db.models import db, Booking
from datetime import datetime, timedelta
from openai import OpenAI
import os
from dotenv import load_dotenv

survey_bp = Blueprint("survey", __name__, url_prefix="/survey")


load_dotenv()
client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))


@survey_bp.route("/result", methods=['POST'])
def esult():
    try:
        data = request.json  # 설문 응답 및 수치 데이터
        
        # 주관적 설문
        overall_health_aware = data.get("overall_health_aware")
        daily_function = data.get("daily_function")
        life_pattern = data.get("life_pattern")
        mental = data.get("mental")
        inconvenience_concern = data.get("inconvenience_concern")
        
        subjective_score = data.get("subjective_score")
        
        subjective_result = jsonify({
            "주관적 점수": subjective_score,
            "전반적 건강 인식": overall_health_aware,
            "일상기능&체력": daily_function,
            "생활습관(운동,수면,식사)": life_pattern,
            "정신/감정 상태": mental,
            "질병 관련 불편함 및 불안": inconvenience_concern
        })
        
        # 객관적 설문
        # 건강검진결과 업로드 했을 경우
        if data.get("upload"):
            score = 100  # 기본 점수 (100점 만점)

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

            
            conditions = {}  # 각 항목 상태를 담을 딕셔너리

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

            # 11. 혈색소
            hemoglobin = data.get("hemoglobin", 0)
            if hemoglobin > 19 or hemoglobin < 7:
                score -= 12
                conditions["hemoglobin"] = "위험"
            elif 16.5 <= hemoglobin <= 18.9 or 7 <= hemoglobin < 10:
                score -= 10 if hemoglobin < 10 else 5
                conditions["hemoglobin"] = "주의"
            elif 10 <= hemoglobin < 12.5:
                score -= 5
                conditions["hemoglobin"] = "주의"
            else:
                conditions["hemoglobin"] = "정상"


            return jsonify({
                "score": score,
                "medications": medications,
                "supplements": supplements,
                "past_conditions": past_conditions,
                "family_history": family_history,
                "conditions": conditions
            })
        # 건강검진결과 업로드 안했을 경우
        else:
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
            
            return jsonify({
                "score": score / 35 * 100
            })

    except Exception as e:
        return jsonify({"message": "Error calculating score", "error": str(e)}), 500
    
    
    
def ask_gpt():
    user_question = request.json.get("question", "")
    if not user_question:
        return jsonify({"error": "No question provided"}), 400

    try:
        response = client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[
                {"role": "system", "content": "You are a helpful assistant."},
                {"role": "user", "content": user_question}
            ],
            max_tokens=300
        )
        answer = response.choices[0].message.content
        return jsonify({"answer": answer})
    except Exception as e:
        return jsonify({"error": str(e)}), 500