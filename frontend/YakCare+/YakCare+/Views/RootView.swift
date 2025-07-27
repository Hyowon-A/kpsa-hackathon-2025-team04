//
//  RootView.swift
//  YakCare+
//
//  Created by 이효주 on 7/26/25.
//

import SwiftUI

struct RootView: View {
    @State private var router = NavigationRouter()
    @StateObject private var signupVM = SignupViewModel()
    @StateObject private var loginVM = ContentsViewModel()
    @StateObject private var surveyVM = SurveyViewModel()
    @StateObject private var imageVM = HealthScoreViewModel()
    
    var body: some View {
        NavigationStack(path: $router.path) {
            LoginView()
                .environment(router)
                .environmentObject(loginVM)
                .navigationDestination(for: Route.self) { route in
                        switch route {
                        case .login:
                            LoginView()
                            // 하위 뷰에 environment로 router를 넘겨준다.
                                .environment(router)
                                .environmentObject(loginVM)
                        case .signup:
                            SignupView()
                                .environment(router)
                                .environmentObject(signupVM)
                        case .home:
                            HomeView().environment(router)
                        case .signup2:
                            SignupView2()
                                .environment(router)
                                .environmentObject(signupVM)
                        case .surveyStep1:
                            SurveyView().environment(router)
                                .environmentObject(surveyVM)
                        case .surveyStep2:
                            SurveyStep2View().environment(router)
                                .environmentObject(surveyVM)
                        case .surveyStep3:
                            SurveyStep3View().environment(router)
                                .environmentObject(surveyVM)
                        case .surveyStep4:
                            SurveyStep4View().environment(router)
                                .environmentObject(surveyVM)
                                .environmentObject(loginVM)
                                .environmentObject(imageVM)
                        case .nearByPharmacy:
                            NearbyPharmacyView().environment(router)
                        case .calendar:
                            CalendarView().environment(router)
                        case .report:
                            HealthReportView().environment(router)
                                .environmentObject(surveyVM)
                        case .cornerSelection:
                            ConcernSelectionView().environment(router)
                    }
                }
        }
    }
}

#Preview {
    RootView()
}
