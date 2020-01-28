
public struct Note {
    public let note: Int
    public let cents: Int

    init(_ note: Int, cents: Int = 0) {
        self.note = note
        self.cents = cents
    }
}
