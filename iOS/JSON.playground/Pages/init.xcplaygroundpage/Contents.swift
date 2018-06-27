//: [Previous](@previous)
//: ## Initialization
//:
//: You 
//:
let json:JSON = [
    "null":     nil,
    "bool":     true,
    "int":      -42,
    "double":   42.195,
    "string":   "漢字、カタカナ、ひらがなと\"引用符\"の入ったstring😇",
    "array":    [nil, true, 1, "one", [1], ["one":1]],
    "object":   [
        "null":nil, "bool":false, "number":0, "string":"" ,"array":[], "object":[:]
    ],
    "url":"https://github.com/dankogai/"
]

let str = """
{
    "null":     null,
    "bool":     true,
    "int":      -42,
    "double":   42.195,
    "string":   "漢字、カタカナ、ひらがなと\\"引用符\\"の入ったstring😇",
    "array":    [null, true, 1, "one", [1], {"one":1}],
    "object":   {
        "null":null, "bool":false, "number":0, "string":"" ,"array":[], "object":{}
    },
    "url":"https://github.com/dankogai/"

}
"""

//: [Next](@next)
