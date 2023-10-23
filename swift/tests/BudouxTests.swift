import BudouX
import XCTest

public class BudouXTests: XCTestCase {
    func test_parse() {
        let model = ["UW4": ["a": 100]]
        let parser = Parser(model: model)
        let result = parser.parse(sentence: "xyzabc")
        let expected = ["xyz", "abc"]
        XCTAssertEqual(expected, result)
    }

    func test_loadDefaultJapaneseParser() {
        let parser = Parser.japanese()
        let result = parser.parse(sentence: "今日は天気です。")
        let expected = ["今日は", "天気です。"]
        XCTAssertEqual(expected, result)
    }
}
