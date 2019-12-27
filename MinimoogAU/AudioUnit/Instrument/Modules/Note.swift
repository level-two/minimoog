struct Note {
    var note: Int
    var cents: Int
}

extension Note {
    var frequency: Double {
        return 440 * exp2((Double(note) + Double(cents)/1200 - 69)/12)
    }
}
