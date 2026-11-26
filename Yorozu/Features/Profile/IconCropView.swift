import SwiftUI
import UIKit

/// 切り抜く写真（fullScreenCover の item 用）
struct CropSource: Identifiable {
    let id = UUID()
    let image: UIImage
}

/// アイコンの切り抜き。角丸正方形の窓に合わせて、ピンチで拡大・ドラッグで位置合わせ。
/// ダブルタップで元に戻す。窓から写真がはみ出さない（空白ができない）範囲に収める。
struct IconCropView: View {
    let image: UIImage
    var onDone: (UIImage) -> Void
    @Environment(\.dismiss) private var dismiss

    /// 1 = 窓にちょうど収まる（短辺が窓の幅）大きさ
    @State private var scale: CGFloat = 1
    @State private var baseScale: CGFloat = 1
    @State private var offset: CGSize = .zero
    @State private var baseOffset: CGSize = .zero

    private let maxScale: CGFloat = 6
    private let outputSide: CGFloat = 512

    var body: some View {
        GeometryReader { geo in
            let side = min(geo.size.width - 40, geo.size.height - 220, 420)
            let fit = side / min(image.size.width, image.size.height)
            let shown = CGSize(width: image.size.width * fit * scale,
                               height: image.size.height * fit * scale)

            ZStack {
                Color.black

                Image(uiImage: image)
                    .resizable()
                    .frame(width: shown.width, height: shown.height)
                    .offset(offset)
                    .position(x: geo.size.width / 2, y: geo.size.height / 2)

                // 窓の外を暗くする
                CropDimmer(side: side, radius: side * 0.24)
                    .fill(.black.opacity(0.6), style: FillStyle(eoFill: true))
                    .allowsHitTesting(false)
                RoundedRectangle(cornerRadius: side * 0.24, style: .continuous)
                    .strokeBorder(.white.opacity(0.85), lineWidth: 1.5)
                    .frame(width: side, height: side)
                    .position(x: geo.size.width / 2, y: geo.size.height / 2)
                    .allowsHitTesting(false)
            }
            .clipped()
            .contentShape(Rectangle())
            .gesture(
                SimultaneousGesture(
                    MagnifyGesture()
                        .onChanged { v in
                            scale = min(max(baseScale * v.magnification, 1), maxScale)
                            offset = clamp(offset, shownFor: scale, fit: fit, side: side)
                        }
                        .onEnded { _ in
                            baseScale = scale
                            offset = clamp(offset, shownFor: scale, fit: fit, side: side)
                            baseOffset = offset
                        },
                    DragGesture()
                        .onChanged { v in
                            let raw = CGSize(width: baseOffset.width + v.translation.width,
                                             height: baseOffset.height + v.translation.height)
                            offset = clamp(raw, shownFor: scale, fit: fit, side: side)
                        }
                        .onEnded { _ in baseOffset = offset }
                )
            )
            .onTapGesture(count: 2) {
                withAnimation(.snappy) {
                    scale = 1; baseScale = 1
                    offset = .zero; baseOffset = .zero
                }
            }
            .overlay(alignment: .top) {
                Text("ピンチで拡大、ドラッグで位置合わせ")
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.8))
                    .padding(.top, 24)
            }
            .overlay(alignment: .bottom) {
                HStack {
                    Button("キャンセル") { dismiss() }
                        .foregroundStyle(.white)
                    Spacer()
                    Button {
                        onDone(render(fit: fit, side: side))
                        dismiss()
                    } label: {
                        Text("決定").font(.headline).padding(.horizontal, 10)
                    }
                    .glassButtonStyle(prominent: true)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
            }
        }
        .background(Color.black.ignoresSafeArea())
        .statusBarHidden()
    }

    /// 写真が窓を必ず覆うように、ずらせる量を制限する
    private func clamp(_ o: CGSize, shownFor s: CGFloat, fit: CGFloat, side: CGFloat) -> CGSize {
        let w = image.size.width * fit * s
        let h = image.size.height * fit * s
        let mx = max(0, (w - side) / 2)
        let my = max(0, (h - side) / 2)
        return CGSize(width: min(max(o.width, -mx), mx), height: min(max(o.height, -my), my))
    }

    /// 窓の中に見えている部分を 512px の正方形に描き出す
    private func render(fit: CGFloat, side: CGFloat) -> UIImage {
        let k = fit * scale                       // 画像 1px が画面で何 pt か
        let shownW = image.size.width * k
        let shownH = image.size.height * k
        // 窓の左上が、画像（画面上）の左上からどれだけ離れているか
        let cropX = (shownW - side) / 2 - offset.width
        let cropY = (shownH - side) / 2 - offset.height
        let crop = CGRect(x: cropX / k, y: cropY / k, width: side / k, height: side / k)

        let out = outputSide / crop.width          // 画像 1px が出力で何 px か
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        return UIGraphicsImageRenderer(size: CGSize(width: outputSide, height: outputSide), format: format).image { _ in
            image.draw(in: CGRect(x: -crop.minX * out, y: -crop.minY * out,
                                  width: image.size.width * out, height: image.size.height * out))
        }
    }
}

/// 画面全体から角丸正方形の窓をくり抜いた形
private struct CropDimmer: Shape {
    let side: CGFloat
    let radius: CGFloat

    func path(in rect: CGRect) -> Path {
        var p = Path(rect)
        p.addRoundedRect(in: CGRect(x: rect.midX - side / 2, y: rect.midY - side / 2, width: side, height: side),
                         cornerSize: CGSize(width: radius, height: radius), style: .continuous)
        return p
    }
}
