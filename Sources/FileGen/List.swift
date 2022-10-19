public struct List: FileContent {
    public let contents: String

    public init<Item>(
        _ items: Array<Item>,
        separatedBy separator: String = "",
        placeItemsOnSeparateLines: Bool = true,
        @File.Builder contents: (Item) -> String
    ) {
        var results = ""
        for (item, index) in zip(items, items.indices) {
            results += contents(item)
            if index < items.endIndex - 1 {
                results += separator + (placeItemsOnSeparateLines ? "\n" : "")
            }
        }
        self.contents = results
    }
}
