# BudouX Swift Module

BudouX is a standalone, small, and language-neutral phrase segmenter tool that
provides beautiful and legible line breaks.

For more details about the project, please refer to the [project README](https://github.com/google/budoux/).

## Demo

<https://google.github.io/budoux>

## Usage

### Simple usage

You can get a list of phrases by feeding a sentence to the parser.
The easiest way is to get a parser is loading the default parser for each language.

```swift
import BudouX

let parser = Parser.japanese()
print(parser.parse(sentence: "今日は良い天気ですね。"))
// [今日は, 良い, 天気ですね。]
```

#### Supported languages and their default parsers

- Japanese: `Parser.japanese()`
- Simplified Chinese: `Parser.simplifiedChinese()`
- Traditional Chinese: `Parser.traditionalChinese()`

## Disclaimer

This is not an officially supported Google product.
