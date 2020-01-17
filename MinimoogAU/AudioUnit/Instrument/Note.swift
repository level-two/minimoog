import Foundation

struct Note {
    var note: Int
    var cents: Int
}

extension Note {
    var frequency: Float32 {
        return 440 * exp2((Float32(note) + Float32(cents)/1200 - 69)/12)
    }
}
