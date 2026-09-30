import Charts
import SwiftUI

struct StatisticsView: View {
    @Environment(AppStore.self) private var store

    var body: some View {
        ScreenContainer {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Statistics")
                            .font(.largeTitle.weight(.bold))
                            .foregroundStyle(.white)
                        Text("Your journey in numbers")
                            .font(.subheadline)
                            .foregroundStyle(Theme.secondaryText)
                    }
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        metricTile(
                            symbol: "thermometer.medium",
                            tint: Theme.warmEnd,
                            value: "\(store.willTemperature)°",
                            caption: "Will Temperature",
                            valueColor: Theme.warmEnd
                        )
                        metricTile(
                            symbol: "chart.line.uptrend.xyaxis",
                            tint: Theme.accent,
                            value: "\(store.awarenessPercent)%",
                            caption: "Awareness",
                            valueColor: Theme.accent
                        )
                        metricTile(
                            symbol: "flame.fill",
                            tint: Theme.ice,
                            value: "\(store.helmDays)",
                            caption: "Days at the Helm",
                            valueColor: .white
                        )
                        metricTile(
                            symbol: "cube",
                            tint: Theme.complete,
                            value: "\(store.iceMeltedPercent)%",
                            caption: "Ice Melted",
                            valueColor: Theme.complete
                        )
                    }
                    SurfaceCard {
                        VStack(alignment: .leading, spacing: 12) {
                            SectionKicker(title: "WEEKLY AWARENESS")
                            Chart(store.weekBars()) { bar in
                                BarMark(
                                    x: .value("Day", bar.label),
                                    y: .value("Awareness", bar.percent)
                                )
                                .foregroundStyle(Theme.blueGradient)
                                .cornerRadius(6)
                            }
                            .chartYScale(domain: 0...100)
                            .chartYAxis(.hidden)
                            .chartXAxis {
                                AxisMarks { _ in
                                    AxisValueLabel()
                                        .font(.caption2)
                                        .foregroundStyle(Theme.secondaryText)
                                }
                            }
                            .frame(height: 140)
                        }
                    }
                    SurfaceCard {
                        VStack(alignment: .leading, spacing: 14) {
                            SectionKicker(title: "BY LIFE SPHERE")
                            if store.sphereShares().isEmpty {
                                Text("No moments yet")
                                    .font(.subheadline)
                                    .foregroundStyle(Theme.secondaryText)
                            } else {
                                ForEach(store.sphereShares()) { share in
                                    VStack(alignment: .leading, spacing: 6) {
                                        HStack {
                                            Text(share.sphere.rawValue)
                                                .font(.subheadline.weight(.semibold))
                                                .foregroundStyle(.white)
                                            Spacer()
                                            Text("\(share.percent)%")
                                                .font(.subheadline.weight(.bold))
                                                .foregroundStyle(Theme.sphereColor(share.sphere))
                                        }
                                        MeterBar(fraction: Double(share.percent) / 100, tint: Theme.sphereColor(share.sphere))
                                    }
                                }
                            }
                        }
                    }
                    iceCard
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
        }
    }

    private var iceCard: some View {
        HStack(spacing: 16) {
            IcebergMark(
                melt: Double(store.iceMeltedPercent) / 100,
                warmth: Double(store.willTemperature) / 100
            )
            .frame(width: 90)
            VStack(alignment: .leading, spacing: 4) {
                SectionKicker(title: "ICE MELTING")
                Text("\(store.iceMeltedPercent)%")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text("ice melted")
                    .font(.subheadline)
                    .foregroundStyle(Theme.secondaryText)
                Text("+\(max(0, store.iceThisWeek))% this week")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.complete)
            }
            Spacer()
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [Theme.accentDeep.opacity(0.55), Theme.card],
                startPoint: .leading,
                endPoint: .trailing
            ),
            in: RoundedRectangle(cornerRadius: Theme.corner, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: Theme.corner, style: .continuous)
                .stroke(Theme.border, lineWidth: 1)
        }
    }

    private func metricTile(symbol: String, tint: Color, value: String, caption: String, valueColor: Color) -> some View {
        SurfaceCard {
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: symbol)
                    .foregroundStyle(tint)
                Text(value)
                    .font(.title.weight(.bold))
                    .foregroundStyle(valueColor)
                Text(caption)
                    .font(.caption)
                    .foregroundStyle(Theme.secondaryText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(minHeight: 96)
        }
    }
}
