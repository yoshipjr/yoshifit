import Foundation

public enum ExerciseSeedData {
    public struct Seed {
        public let name: String
        public let muscleGroup: MuscleGroup
    }

    public static let all: [Seed] = [
        // 胸
        Seed(name: "ベンチプレス", muscleGroup: .chest),
        Seed(name: "インクラインベンチプレス", muscleGroup: .chest),
        Seed(name: "ダンベルベンチプレス", muscleGroup: .chest),
        Seed(name: "ディップス", muscleGroup: .chest),
        Seed(name: "加重ディップス", muscleGroup: .chest),
        Seed(name: "ダンベルフライ", muscleGroup: .chest),
        Seed(name: "インクラインダンベルフライ", muscleGroup: .chest),
        Seed(name: "ケーブルクロスオーバー", muscleGroup: .chest),

        // 背中
        Seed(name: "プルアップ（順手懸垂）", muscleGroup: .back),
        Seed(name: "加重懸垂", muscleGroup: .back),
        Seed(name: "ラットプルダウン", muscleGroup: .back),
        Seed(name: "ベントオーバーロウ", muscleGroup: .back),
        Seed(name: "ダンベルロウ", muscleGroup: .back),
        Seed(name: "Tバーロウ", muscleGroup: .back),
        Seed(name: "シーテッドケーブルロウ", muscleGroup: .back),
        Seed(name: "デッドリフト", muscleGroup: .back),

        // 肩
        Seed(name: "ショルダープレス", muscleGroup: .shoulder),
        Seed(name: "ダンベルショルダープレス", muscleGroup: .shoulder),
        Seed(name: "サイドレイズ", muscleGroup: .shoulder),
        Seed(name: "ダンベルサイドレイズ", muscleGroup: .shoulder),
        Seed(name: "リアレイズ", muscleGroup: .shoulder),
        Seed(name: "アップライトロウ", muscleGroup: .shoulder),
        Seed(name: "フェイスプル", muscleGroup: .shoulder),
        Seed(name: "アーノルドプレス", muscleGroup: .shoulder),

        // 二頭・前腕
        Seed(name: "バーベルカール", muscleGroup: .biceps),
        Seed(name: "ダンベルカール", muscleGroup: .biceps),
        Seed(name: "ダンベルハンマーカール", muscleGroup: .biceps),
        Seed(name: "インクラインダンベルカール", muscleGroup: .biceps),
        Seed(name: "プリチャーカール", muscleGroup: .biceps),
        Seed(name: "ケーブルカール", muscleGroup: .biceps),
        Seed(name: "リストカール", muscleGroup: .biceps),

        // 三頭
        Seed(name: "ナローベンチプレス", muscleGroup: .triceps),
        Seed(name: "トライセプスエクステンション", muscleGroup: .triceps),
        Seed(name: "ケーブルプレスダウン", muscleGroup: .triceps),
        Seed(name: "ダンベルキックバック", muscleGroup: .triceps),
        Seed(name: "フレンチプレス", muscleGroup: .triceps),

        // 脚
        Seed(name: "スクワット", muscleGroup: .legs),
        Seed(name: "レッグプレス", muscleGroup: .legs),
        Seed(name: "レッグエクステンション", muscleGroup: .legs),
        Seed(name: "レッグカール", muscleGroup: .legs),
        Seed(name: "ランジ", muscleGroup: .legs),
        Seed(name: "ブルガリアンスクワット", muscleGroup: .legs),
        Seed(name: "カーフレイズ", muscleGroup: .legs),
        Seed(name: "ヒップスラスト", muscleGroup: .legs),

        // 腹筋
        Seed(name: "クランチ", muscleGroup: .abs),
        Seed(name: "シットアップ", muscleGroup: .abs),
        Seed(name: "レッグレイズ", muscleGroup: .abs),
        Seed(name: "プランク", muscleGroup: .abs),
        Seed(name: "ロシアンツイスト", muscleGroup: .abs),
        Seed(name: "ケーブルクランチ", muscleGroup: .abs),
    ]
}
