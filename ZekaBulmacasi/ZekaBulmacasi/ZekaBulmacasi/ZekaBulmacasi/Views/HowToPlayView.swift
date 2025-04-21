// HowToPlayView.swift
import SwiftUI

struct HowToPlayView: View {
    @Binding var path: NavigationPath

    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Başlık
                    Text("Nasıl Oynanır")
                        .font(AppTypography.title)
                        .foregroundColor(.black)
                        .padding(.top, 50)
                        .frame(maxWidth: .infinity, alignment: .center)

                    // Kural 1: Hücrelerin Durumu
                    VStack(alignment: .leading, spacing: 10) {
                        Text("6x6 tahtadaki her hücreyi siyah veya beyaz taş ile doldurun.")
                            .font(AppTypography.body)
                            .foregroundColor(.black)
                        HStack(alignment: .center, spacing: 10) {
                            Text("⚪")
                                .font(.system(size: 24))
                            Text("veya")
                                .font(AppTypography.body)
                                .foregroundColor(.black)
                            Text("⚫")
                                .font(.system(size: 24))
                        }
                    }
                    .padding(.horizontal)

                    // Kural 2: Yakınlık Kuralı
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Yatay veya dikey olarak aynı türden (⚪ veya ⚫) en fazla 2 taş yan yana olabilir.")
                            .font(AppTypography.body)
                            .foregroundColor(.black)
                        HStack(alignment: .center, spacing: 10) {
                            Text("⚪⚪")
                                .font(.system(size: 24))
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                        HStack(alignment: .center, spacing: 10) {
                            Text("⚪⚪⚪")
                                .font(.system(size: 24))
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                        }
                    }
                    .padding(.horizontal)

                    // Kural 3: Satır ve Sütun Dengesi
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Her satır ve sütunda eşit sayıda ⚪ ve ⚫ olmalıdır (3 ⚪ ve 3 ⚫).")
                            .font(AppTypography.body)
                            .foregroundColor(.black)
                        HStack(alignment: .center, spacing: 10) {
                            Text("⚪⚪⚪⚫⚫⚫")
                                .font(.system(size: 24))
                        }
                    }
                    .padding(.horizontal)

                    // Kural 4: Eşitlik İşareti
                    VStack(alignment: .leading, spacing: 10) {
                        Text("= işaretiyle ayrılan taşlar aynı türde olmalıdır.")
                            .font(AppTypography.body)
                            .foregroundColor(.black)
                        HStack(alignment: .center, spacing: 10) {
                            Text("⚪ = ⚪")
                                .font(.system(size: 24))
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                    .padding(.horizontal)

                    // Kural 5: Çarpı İşareti
                    VStack(alignment: .leading, spacing: 10) {
                        Text("X işaretiyle ayrılan taşlar zıt türde olmalıdır.")
                            .font(AppTypography.body)
                            .foregroundColor(.black)
                        HStack(alignment: .center, spacing: 10) {
                            Text("⚪ X ⚫")
                                .font(.system(size: 24))
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                    .padding(.horizontal)

                    // Kural 6: Çözüm Yöntemi
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Her bulmacanın tek bir doğru çözümü vardır.")
                            .font(AppTypography.body)
                            .foregroundColor(.red)
                    }
                    .padding(.horizontal)

                    // Geri Dön Butonu
                    Button(action: {
                        path.removeLast()
                    }) {
                        Text("Geri Dön")
                            .font(AppTypography.subtitle)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 20)
                }
                .padding(.horizontal)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}
