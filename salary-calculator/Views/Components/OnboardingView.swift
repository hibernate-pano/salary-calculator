import SwiftUI

struct OnboardingPage: Identifiable {
    let id = UUID()
    let image: String
    let title: String
    let description: String
}

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var currentPage = 0

    private let pages = [
        OnboardingPage(
            image: "dollarsign.circle.fill",
            title: "看着工资实时增长",
            description: "上班时间里，你赚的每一秒都在屏幕上跳动"
        ),
        OnboardingPage(
            image: "slider.horizontal.3",
            title: "几步完成设置",
            description: "填上月薪和上下班时间，剩下的交给它"
        ),
        OnboardingPage(
            image: "calendar.badge.clock",
            title: "今日 · 本月 · 年度",
            description: "随时看到你今天、这个月、今年赚了多少"
        )
    ]

    var body: some View {
        VStack {
            TabView(selection: $currentPage) {
                ForEach(pages.indices, id: \.self) { index in
                    VStack(spacing: 24) {
                        Image(systemName: pages[index].image)
                            .font(.system(size: 80))
                            .foregroundStyle(.green)
                            .padding(.top, 80)

                        Text(pages[index].title)
                            .font(.title.bold())

                        Text(pages[index].description)
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 40)

                        Spacer()
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))

            Button(action: {
                if currentPage < pages.count - 1 {
                    withAnimation { currentPage += 1 }
                } else {
                    withAnimation { isPresented = false }
                }
            }) {
                Text(currentPage < pages.count - 1 ? "下一步" : "开始使用")
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color.green)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
        }
    }
}

#Preview {
    OnboardingView(isPresented: .constant(true))
}
