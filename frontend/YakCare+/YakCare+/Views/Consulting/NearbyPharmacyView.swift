//
//  NearbyPharmacyView.swift
//  YakCare+
//
//  Created by 이효주 on 7/26/25.
//

import SwiftUI

// MARK: - 더미 모델
struct Pharmacy: Identifiable {
    let id = UUID()
    let name: String
    let hours: String
    let address: String
}

// MARK: - 메인 뷰
struct NearbyPharmacyView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(NavigationRouter.self) private var router
    @State private var searchText: String = ""
    
    // 샘플 데이터
    private let pharmacies: [Pharmacy] = [
        Pharmacy(name: "00약국", hours: "10:00 - 19:00", address: "주소"),
        Pharmacy(name: "00약국", hours: "10:00 - 19:00", address: "주소"),
        Pharmacy(name: "00약국", hours: "10:00 - 19:00", address: "주소"),
        Pharmacy(name: "00약국", hours: "10:00 - 19:00", address: "주소"),
        Pharmacy(name: "00약국", hours: "10:00 - 19:00", address: "주소"),
        Pharmacy(name: "00약국", hours: "10:00 - 19:00", address: "주소")
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // NavBar
            NearbyPharmacyNavBar(title: "가까운 약국을 찾아볼까요?") {
                dismiss()
            }
            .padding(.vertical, 12)
            
            // Search Bar
            NearbyPharmacySearchBar(searchText: $searchText) {
                // 현재 위치로 업데이트
            }
            .padding(.top, 12)
            
            // Sort Label
            NearbyPharmacySortLabel(text: "거리순")
                .padding(.top, 16)
            
            // List
            ScrollView {
                VStack(spacing: 9) {
                    ForEach(pharmacies) { item in
                        PharmacyRow(pharmacy: item) {
                            // 예약 액션
                            router.push(.calendar)
                        }
                    }
                }
                .padding(.vertical, 12)
            }
            
            Spacer().frame(height: 15)
        }
        .background(Color.white.ignoresSafeArea())
        .navigationBarBackButtonHidden()
    }
}

// MARK: - NavBar 컴포넌트
struct NearbyPharmacyNavBar: View {
    let title: String
    let onBack: () -> Void
    
    var body: some View {
        ZStack {
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.black)
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            
            HStack {
                Spacer()
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
            }
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - SearchBar 컴포넌트
struct NearbyPharmacySearchBar: View {
    @Binding var searchText: String
    let onLocate: () -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
            TextField("서울시 강남구 / 강남역", text: $searchText)
                .font(.system(size: 14))
            Button(action: onLocate) {
                Image("Location")
            }
        }
        .padding(.vertical, 13)
        .padding(.horizontal, 12)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal, 16)
    }
}

// MARK: - SortLabel 컴포넌트
struct NearbyPharmacySortLabel: View {
    let text: String
    
    var body: some View {
        HStack {
            Text(text)
                .font(.system(size: 14, weight: .medium))
            Spacer()
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - PharmacyRow 컴포넌트
struct PharmacyRow: View {
    let pharmacy: Pharmacy
    let onReserve: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(pharmacy.name)
                        .font(.system(size: 16, weight: .semibold))
                    Image("TimeCircle")
                        .resizable()
                        .frame(width: 12, height: 12)
                    Spacer().frame(width: 5)
                    Text(pharmacy.hours)
                        .font(.system(size: 12))
                }
                Text(pharmacy.address)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            Spacer()
            Button(action: onReserve) {
                Text("예약하기")
                    .font(.system(size: 14, weight: .medium))
                    .frame(width: 80, height: 60)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(12)
            }
        }
        .padding(12)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal, 16)
    }
}

struct NearbyPharmacyView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            NearbyPharmacyView()
                .environment(NavigationRouter())
        }
    }
}
