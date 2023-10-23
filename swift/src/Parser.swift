/*
 * Copyright 2023 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     https://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import Foundation

/// The BudouX parser that translates the input sentence into phrases.
///
/// You can create a parser instance by invoking `Parser(model: model)` with the model data you
/// want to use. You can also create a parser by specifying the model file path with {@code
/// Parser(path: modelFileName)}.
///
/// In most cases, it's sufficient to use the default parser for the language. For example, you
/// can create a default Japanese parser by invoking `let parser = Parser.japanese()`
public struct Parser {
	private let model: [String: [String: Int]]

	/// Constructs a BudouX parser.
	/// @param model the model data.
	public init(model: [String: [String: Int]]) {
		self.model = model
	}

	/// Loads a parser by specifying the model file path.
	///
	/// @param modelFileName the model file path.
	/// @return a BudouX parser.
	public init(modelFileName filePath: String) throws {
		let url = URL(fileURLWithPath: filePath)
		let data = try Data(contentsOf: url, options: [.uncached, .alwaysMapped])
		let decoder = JSONDecoder()
		let model = try decoder.decode([String: [String: Int]].self, from: data)

		self.init(model: model)
	}
}

extension Parser {

	/// Loads the default Japanese parser.
    ///
    /// @return a BudouX parser with the default Japanese model.
    public static func japanese() -> Parser {
        try! self.init(modelFileName: "ja.json")
    }

	/// Loads the default Japanese parser.
	///
	/// @return a BudouX parser with the default Simplified Chinese model.
    public static func simplifiedChinese() -> Parser {
        try! self.init(modelFileName: "zh-hans.json")
    }

	/// Loads the default Japanese parser.
	///
	/// @return a BudouX parser with the default Traditional Chinese model.
    public static func traditionalChinese() -> Parser {
        try! self.init(modelFileName: "zh-hant.json")
    }
}

extension Parser {

	/// Gets the score for the specified feature of the given sequence.
	///
	/// @param featureKey the feature key to examine.
	/// @param sequence the sequence to look up the score.
	/// @return the contribution score to support a phrase break.
    private func score(feature key: String, sequence: Substring) -> Int {
        model[key]?[String(sequence)] ?? 0
    }
}

extension Parser {

	/// Translates an HTML string with phrases wrapped in no-breaking markup.
	///
	/// @param html an HTML string.
	/// @return the translated HTML string with no-breaking markup.
    public func parse(html fragment: String, encoding: String.Encoding = .utf8) throws -> [String] {
        fatalError("not implemented")
    }

	/// Parses a sentence into phrases.
	///
	/// @param sentence the sentence to break by phrase.
	/// @return a list of phrases.
    public func parse(sentence: String) -> [String] {
        guard !sentence.isEmpty else {
            return []
        }

        var results = [String]()
        results.append(String(sentence.prefix(1)))

        let totalScore = model     //  start: {"UW1": ["…": 1, "…": 2, …], "UW2": ["…", 3, …], …}
            .values                // result: [["…": 1, "…": 2, …], ["…", 3, …]]
            .flatMap { $0.values } // result: [1, 2, 3, …]
            .reduce(0, +)          // result: sum(1, 2, 3, …)

        for i in 1 ..< sentence.count {
            var score = -totalScore
            if i - 2 > 0 {
                score += 2 * self.score(feature: "UW1", sequence: sentence[i - 3..<i - 2])
            }
            if i - 1 > 0 {
                score += 2 * self.score(feature: "UW2", sequence: sentence[i - 2..<i - 1])
            }

            score += 2 * self.score(feature: "UW3", sequence: sentence[i - 1..<i])
            score += 2 * self.score(feature: "UW4", sequence: sentence[i..<i + 1])

            if i + 1 < sentence.count {
                score += 2 * self.score(feature: "UW5", sequence: sentence[i + 1..<i + 2])
            }
            if i + 2 < sentence.count {
                score += 2 * self.score(feature: "UW6", sequence: sentence[i + 2..<i + 3])
            }
            if i > 1 {
                score += 2 * self.score(feature: "BW1", sequence: sentence[i - 2..<i])
            }

            score += 2 * self.score(feature: "BW2", sequence: sentence[i - 1..<i + 1])

            if i + 1 < sentence.count {
                score += 2 * self.score(feature: "BW3", sequence: sentence[i..<i + 2])
            }
            if i - 2 > 0 {
                score += 2 * self.score(feature: "TW1", sequence: sentence[i - 3..<i])
            }
            if i - 1 > 0 {
                score += 2 * self.score(feature: "TW2", sequence: sentence[i - 2..<i + 1])
            }
            if i + 1 < sentence.count {
                score += 2 * self.score(feature: "TW3", sequence: sentence[i - 1..<i + 2])
            }
            if i + 2 < sentence.count {
                score += 2 * self.score(feature: "TW4", sequence: sentence[i..<i + 3])
            }
            if score > 0 {
                results.append("")
            }
            results[results.count - 1] = results[results.count - 1] + sentence[i..<i + 1]
        }

        return results
    }
}

fileprivate extension String {
    subscript(bounds: CountableRange<Int>) -> Substring {
        let lowerBound = index(startIndex, offsetBy: bounds.lowerBound)
        let upperBound = index(startIndex, offsetBy: bounds.upperBound)
        return self[lowerBound..<upperBound]
    }
}
