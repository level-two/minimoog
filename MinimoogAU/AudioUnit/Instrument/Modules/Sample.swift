struct Sample {
    let left: Double
    let right: Double
}

extension Sample {
    public static func +(lhs: Sample, rhs: Sample) -> Sample {
        return Sample(left: lhs.left + rhs.left, right: lhs.right + rhs.right)
    }
}
