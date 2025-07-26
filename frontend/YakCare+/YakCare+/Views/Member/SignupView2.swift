import SwiftUI



// MARK: — SignupView2
struct SignupView2: View {
    @Environment(NavigationRouter.self) private var router
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var signupVM: SignupViewModel

    // 직업군
    @State private var jobGroup: String = "사무직"
    @State private var customJob: String = ""
    private let jobOptions = ["사무직", "현장직", "운전직", "교육/연구직", "서비스직", "의료/보건직", "IT/디지털 직군",
    "예술/엔터테인먼트", "군/소방/경찰","농/어업 종사자","체육 관련직","가사/육아 담당자","학생", "기타"]

    // 근무형태
    @State private var workType: String = ""
    @State private var customWorkType: String = ""
    private let workTypeRows: [[String]] = [
        ["주간 근무", "야간 근무"],
        ["교대 근무", "재택/원격 근무"],
        ["외근/출장형 근무", "프리랜서/유동형"],
        ["무직/휴직 중"]
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // back button + title
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(.black)
                    }
                    Spacer()
                }
                HStack {
                    Spacer().frame(width: 20)
                    Text("프로필 설정")
                        .font(.system(size: 22, weight: .semibold))
                    Spacer()
                }

                // MARK: — 직업군
                DropdownField(
                    title: "직업군",
                    selection: $jobGroup,
                    options: jobOptions
                )

                // 기타 직접 입력 (직업군)
                TextField("기타 직접입력", text: $customJob)
                    .padding()
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(12)

                // MARK: — 근무형태
                Text("근무형태")
                    .font(.system(size: 14))
                    .frame(maxWidth: .infinity, alignment: .leading)

                VStack(spacing: 8) {
                    ForEach(workTypeRows, id: \.self) { row in
                        HStack(spacing: 8) {
                            ForEach(row, id: \.self) { option in
                                OptionButton(
                                    title: option,
                                    isSelected: workType == option
                                ) {
                                    workType = option
                                }
                            }
                        }
                    }
                }

                // 기타 직접 입력 (근무형태)
                TextField("기타 직접입력", text: $customWorkType)
                    .padding()
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(12)

                Spacer()
                
                // 확인 버튼
                Button(action: {
                    // ViewModel에 직업, 근무형태 반영
                    signupVM.occupation = customJob.isEmpty ? jobGroup : customJob
                    signupVM.workStyle = customWorkType.isEmpty ? workType : customWorkType

                    // UserData 생성 및 회원가입 요청
                    let user = UserData(
                        email: signupVM.email,
                        password: signupVM.password,
                        name: signupVM.name,
                        dob: signupVM.dob,
                        gender: signupVM.gender,
                        occupation: signupVM.occupation,
                        work_style: signupVM.workStyle
                    )

                    signupVM.createUser(user)

                    // 홈으로 이동
                    router.push(.home)
                })
                {
                    Text("확인")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(25)
                }
                .padding(.top, 16)
            }
            .padding(.horizontal, 16)
        }
        .navigationBarBackButtonHidden()
    }
}

// MARK: — DropdownField
struct DropdownField: View {
    let title: String
    @Binding var selection: String
    let options: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14))
            Menu {
                ForEach(options, id: \.self) { option in
                    Button(option) {
                        selection = option
                    }
                }
            } label: {
                HStack {
                    Text(selection)
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.system(size: 16, weight: .medium))
                }
                .padding()
                .background(Color.gray.opacity(0.3))
                .cornerRadius(12)
            }
        }
    }
}

// MARK: — OptionButton
struct OptionButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .frame(maxWidth: .infinity)
                .padding()
                .background(isSelected ? Color.blue.opacity(0.2) : Color.gray.opacity(0.3))
                .cornerRadius(12)
        }
    }
}

// MARK: — Preview
struct SignupView2_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SignupView2()
                .environment(NavigationRouter())
        }
    }
}
