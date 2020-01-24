
public struct Note {
    let note: Int
    let cents: Int

    init(_ note: Int, cents: Int = 0) {
        self.note = note
        self.cents = cents
    }
}
