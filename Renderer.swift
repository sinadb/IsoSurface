//
//  Renderer.swift
//  bare
//
//  Created by Sina Dashtebozorgy on 24/01/2024.
//

import Foundation
import Metal
import MetalKit
import AppKit
import MetalFX
import RegexBuilder
func returnPostFix(inFix : String) -> [String] {
    let s = "(x|y|z)"
        let cosReg = "cos"
        let sinReg = "sin"
        let tanReg = "tan"
        //let trigs = "\(cosReg)|\(sinReg)|\(tanReg)"
    let regex = try! NSRegularExpression(pattern: "(\(cosReg)|\(sinReg)|\(tanReg))|[0-9]+|[a-z]|(\\(|\\)|\\+|\\-|\\*|\\/)|(\\^[1-9]+)")
    var word = inFix
    let matches = regex.matches(in: word, range: NSRange(location: 0, length: word.count))

    let nString = word as NSString
    var postFix = [String]()
    var stack = [String]()
    var precedence = [String : Int]()
    precedence["("] = -1
    precedence[")"] = -1
    precedence["+"] = 1
    precedence["-"] = 1
    precedence["*"] = 2
    precedence["/"] = 2
    precedence["^"] = 3
    for i in 1...9 {
        precedence[String(i)] = 2
    }
    precedence["cos"] = 3
    precedence["sin"] = 3
    precedence["tan"] = 3
    
    let trigs = ["cos","sin","tan"]

    for m in matches {
        let current_match = nString.substring(with: m.range)
        print("postFix is :\(postFix)")
        print("stack is :\(stack)")
        print("current match is :\(current_match)")
        if(current_match == "x" || current_match == "y" || current_match == "z"){
            postFix.append(current_match)
            
        }
        else{
            if(stack.count == 0 || current_match == "("){
                stack.append(current_match)
                

            }
            else{
                
                //print("stack is :\(stack)")
                var found_lesser_precedence = true
                while(stack.count != 0 && found_lesser_precedence){
                    
                    let top = stack.last!
                    //print("top comparator is :\(top)")
                    var comparatorCurrnet = (current_match)
                    if((comparatorCurrnet as NSString).substring(with: NSRange(0..<1)) == "^"){
                        comparatorCurrnet = (comparatorCurrnet as NSString).substring(with: NSRange(0..<1))
                    }
                    var comparatorTop = top
                    if((comparatorTop as NSString).substring(with: NSRange(0..<1)) == "^"){
                        comparatorTop = (comparatorTop as NSString).substring(with: NSRange(0..<1))
                    }
                    if(comparatorTop == "(" && comparatorCurrnet == ")"){
                        stack.popLast()
                        break
                    }
                    
                    print(stack.count)
                    //print("currnet comparator is : \(comparatorCurrnet)")
                    
                    // if we have reached a ")" then pop all of the stack
                    if(comparatorCurrnet == ")"){
                        //print("here")
                        for op in stack.reversed() {
                            print("current op is \(op)")
                            print("stack is :\(stack)")
                            print("postFix is \(postFix)")
                            if((op as NSString).substring(with: NSRange(0..<1)) == "^"){
                                let first = (top as NSString).substring(with: NSRange(0..<1))
                                let last = (top as NSString).substring(with: NSRange(1..<2))
                                postFix.append(first)
                                postFix.append(last)
                                stack.popLast()
                            }
                            else if(op == "("){
                                //print("breaking out of loop")
                                    stack.popLast()
                                    found_lesser_precedence = false
                                    break
                            }
                            else{
                                postFix.append(stack.popLast()!)
                            }
                        }
                    }
                    
                    else if((comparatorCurrnet != "(") && precedence[comparatorTop]! >= precedence[comparatorCurrnet]!){
                        if((top as NSString).substring(with: NSRange(0..<1)) == "^"){
                            let first = (top as NSString).substring(with: NSRange(0..<1))
                            let last = (top as NSString).substring(with: NSRange(1..<2))
                            postFix.append(first)
                            postFix.append(last)
                            stack.popLast()
                        }
                            else{
                                postFix.append(stack.popLast()!);
                            }
                        }
                    
                    else{
                        found_lesser_precedence = false
                    }
                }
                if(current_match != ")"){
                    stack.append(current_match)
                }
            }
        }
        
        
    }
    print("stack is :\(stack)")
    while(stack.count != 0){
        let top = stack.last!
        print("top is : \(top)")
        if((top as NSString).substring(with: NSRange(0..<1)) == "^"){
            let first = (top as NSString).substring(with: NSRange(0..<1))
            let last = (top as NSString).substring(with: NSRange(1..<2))
            postFix.append(first)
            postFix.append(last)
            stack.popLast()
        }
        else {
            postFix.append(stack.popLast()!)
        }
        
    }
    return postFix
}
//func returnPostFix(inFix : String) -> [String] {
//    let s = "(x|y|z)"
//        let cosReg = "cos"
//        let sinReg = "sin"
//        let tanReg = "tan"
//        //let trigs = "\(cosReg)|\(sinReg)|\(tanReg)"
//    let regex = try! NSRegularExpression(pattern: "(\(cosReg)|\(sinReg)|\(tanReg))|[0-9]+|[a-z]|(\\(|\\)|\\+|\\-|\\*|\\/)|(\\^[1-9]+)")
//    var word = inFix
//    let matches = regex.matches(in: word, range: NSRange(location: 0, length: word.count))
//
//    let nString = word as NSString
//    var postFix = [String]()
//    var stack = [String]()
//    var precedence = [String : Int]()
//    precedence["("] = -1
//    precedence[")"] = -1
//    precedence["+"] = 1
//    precedence["-"] = 1
//    precedence["*"] = 2
//    precedence["/"] = 2
//    precedence["^"] = 3
//    for i in 1...9 {
//        precedence[String(i)] = 2
//    }
//    precedence["cos"] = 0
//    precedence["sin"] = 0
//    precedence["tan"] = 0
//    
//    let trigs = ["cos","sin","tan"]
//
//    for m in matches {
//        let current_match = nString.substring(with: m.range)
//        if(current_match == "x" || current_match == "y" || current_match == "z"){
//            postFix.append(current_match)
//            print("postFix is :\(postFix)")
//        }
//        else{
//            if(stack.count == 0 || current_match == "("){
//                stack.append(current_match)
//                print("stack is :\(stack)")
//                
//
//            }
//            else{
//                print("stack is :\(stack)")
//                var found_lesser_precedence = true
//                while(stack.count != 0 && found_lesser_precedence){
//                    let top = stack.last!
//                    print("top comparator is :\(top)")
//                    var comparatorCurrnet = (current_match)
//                    if((comparatorCurrnet as NSString).substring(with: NSRange(0..<1)) == "^"){
//                        comparatorCurrnet = (comparatorCurrnet as NSString).substring(with: NSRange(0..<1))
//                    }
//                    var comparatorTop = top
//                    if((comparatorTop as NSString).substring(with: NSRange(0..<1)) == "^"){
//                        comparatorTop = (comparatorTop as NSString).substring(with: NSRange(0..<1))
//                    }
//                    if(comparatorTop == "("){
//                        break
//                    }
//                    print("currnet comparator is : \(comparatorCurrnet)")
//                    
//                    // if we have reached a ")" then pop all of the stack
//                    if(comparatorCurrnet == ")"){
//                        for op in stack.reversed() {
//                            print("current op is \(op)")
//                            print("stack is :\(stack)")
//                            print("postFix is \(postFix)")
//                            if((op as NSString).substring(with: NSRange(0..<1)) == "^"){
//                                let first = (top as NSString).substring(with: NSRange(0..<1))
//                                let last = (top as NSString).substring(with: NSRange(1..<2))
//                                postFix.append(first)
//                                postFix.append(last)
//                                stack.popLast()
//                            }
//                            else if(op == "("){
//                                print("breaking out of loop")
//                                    stack.popLast()
//                                    found_lesser_precedence = false
//                                    break
//                            }
//                            else{
//                                postFix.append(stack.popLast()!)
//                            }
//                        }
//                    }
//                    
//                    else if((comparatorCurrnet != "(") && precedence[comparatorTop]! >= precedence[comparatorCurrnet]!){
//                        if((top as NSString).substring(with: NSRange(0..<1)) == "^"){
//                            let first = (top as NSString).substring(with: NSRange(0..<1))
//                            let last = (top as NSString).substring(with: NSRange(1..<2))
//                            postFix.append(first)
//                            postFix.append(last)
//                            stack.popLast()
//                        }
//                            else{
//                                postFix.append(stack.popLast()!);
//                            }
//                        }
//                    
//                    else{
//                        found_lesser_precedence = false
//                    }
//                }
//                if(current_match != ")"){
//                    stack.append(current_match)
//                }
//            }
//        }
//        
//        
//    }
//
//    while(stack.count != 0){
//        let top = stack.last!
//        if((top as NSString).substring(with: NSRange(0..<1)) == "^"){
//            let first = (top as NSString).substring(with: NSRange(0..<1))
//            let last = (top as NSString).substring(with: NSRange(1..<2))
//            postFix.append(first)
//            postFix.append(last)
//        }
//        else {
//            postFix.append(top)
//        }
//        stack.popLast()
//    }
//    return postFix
//}




func createNodes(postFix : [String], nodesList : inout [MTLFunctionStitchingNode], nodesDic : inout [String : MTLFunctionStitchingFunctionNode], callCount : Int, nodeNameOffset : Int) -> Void {
    

    
    var equation = postFix
    print("equation is :\(equation)")
    let srcA = MTLFunctionStitchingInputNode(argumentIndex: 0)
    let srcB = MTLFunctionStitchingInputNode(argumentIndex: 1)
    let srcC = MTLFunctionStitchingInputNode(argumentIndex : 2)
    
    var operators = [
        "+" : "add",
        "-" : "minus",
        "*" : "multiply",
        "/" : "divide",
        "^" : "square",
        
    ]
    
    for i in 2...9 {
        let opName = "/" + String(i)
        let functionName = "divide_" + String(i)
        operators[opName] = functionName
    }
    
    operators["cos"] = "cos_a"
    operators["sin"] = "sin_a"
    operators["tan"] = "tan_a"
    
    
    
    for i in 1...9 {
        operators[String(i)] = "factors"
    }

    let inputNodes = [
        "x" : srcA,
        "y" : srcB,
        "z" : srcC
    ]

   
    // read the strings until we have found an operator
    var current_index = 0
    while(operators[postFix[current_index]] == nil){
        print("we have this operator : \(postFix[current_index])")
        current_index += 1
    }
    var op = postFix[current_index]
    print("operator found is :\(postFix[current_index])")
    // if it's division look one ahead and combine the two to create one operator
    if(op == "/"){
        if(current_index != postFix.count - 1){
            
            let temp_op = op + postFix[current_index + 1]
            if(operators[temp_op] != nil){
                op = temp_op
            }
        }
    }

    // find operator index and then start reading form 0th index up to before the operator

    var inputs = [MTLFunctionStitchingNode]()
    var unusedNodes = [srcA,srcB,srcC]
    var inputNodesUsesCount = 0
    print(operators[op]!)
    //print(operators["+"]?.contains("_"))
    let startIndex = (operators[op] == "factors" || op == "^" || operators[op]!.contains("_") || operators[op]!.contains("_a")) ? current_index - 1 : current_index - 2
    
    for i in startIndex..<current_index {
        print("iter number is :\(i)")
        if let node = inputNodes[postFix[i]] {
            //print("the input is :\(inputNodes[postFix[i]])")
            inputs.append(node)
            inputNodesUsesCount += 1
            if(unusedNodes.contains(node)){
                unusedNodes.removeAll(where: {$0 == node})
            }
            
        }
        else{
            print("node is : \(postFix[i])")
            if let node = nodesDic[postFix[i]]{
                inputs.append(node)
            }
        }
    }
    for i in 0..<(3 - inputs.count){
        //print("unused node is :\(unusedNodes[i])")
        inputs.append(unusedNodes[i])
    }
    //print("inputs is :\(inputs)")
    // deal with the special case of exponent here
    
    
    if(operators[op] == "factors"){
        var nodeCount = 0
        var currentLoopNodes = [MTLFunctionStitchingFunctionNode]()
        var functionName = "add"
        var factor = (op as NSString).integerValue
        let iterationCount = factor / 3
        var finalNodeName = String()
        
        
        for i in 0..<(factor - 1) {
            print("loop count :\(i)")
            let currentLoop_inputs : [MTLFunctionStitchingNode] =
            (currentLoopNodes.last == nil) ? inputs :
            [
                currentLoopNodes.last!,
                inputs[0],
                srcA
            ]
            let currentLoop_node = MTLFunctionStitchingFunctionNode(name: nodeCount == 0 ? "times2" : "add", arguments: currentLoop_inputs, controlDependencies: [])
            let nodeName = "factorNode" + String(callCount + nodeCount + nodeNameOffset)
            finalNodeName = nodeName
            currentLoopNodes.append(currentLoop_node)
            nodesDic[nodeName] = currentLoop_node
            nodesList.append(currentLoop_node)
            nodeCount += 1
            
            
        }
        
        
        equation.insert(finalNodeName, at: current_index - 1)
        equation.removeSubrange(current_index...current_index+1)
        if(equation.count > 1){
            createNodes(postFix: equation, nodesList: &nodesList, nodesDic: &nodesDic, callCount: callCount + 1, nodeNameOffset: nodeCount)
        }

        
    }
    
    
    else if(op == "^"){
        // find the exponent
        var nodeCount = 0
        var currentLoopNodes = [MTLFunctionStitchingFunctionNode]()
        var functionName = operators[op]!
        var exponent = (postFix[current_index + 1] as NSString).integerValue
        // create a square node first
        //let squareNode = MTLFunctionStitchingFunctionNode(name: functionName, arguments: inputs, controlDependencies: [])
        // add square node to the list of nodes
        //nodesList.append(squareNode)
        //currentLoopNodes.append(squareNode)
        // we need to remove from call count up to one past currentIndex
        //let squareNodeName = "squareNode" + String(callCount + nodeCount)
        //equation.append(squareNodeName)
        
        let powersOf2 = Int(log2(Double(exponent)))
        // for instance if exponent is 6 we just need to create a 3 * square node
        //var squareNodesCount = exponent / 2
        
        //nodeCount += 1
        var finalNodeName = String()
        for i in 0..<powersOf2 {
            print("loop count :\(i)")
            let currentLoop_inputs : [MTLFunctionStitchingNode] =
            (currentLoopNodes.last == nil) ? inputs :
            [
                currentLoopNodes.last!,
                currentLoopNodes.first!,
                srcA
            ]
            let currentLoop_node = MTLFunctionStitchingFunctionNode(name: nodeCount == 0 ? "square" : "multiply" , arguments: currentLoop_inputs, controlDependencies: [])
            let nodeName = "powerNode" + String(callCount + nodeCount + nodeNameOffset)
            finalNodeName = nodeName
            currentLoopNodes.append(currentLoop_node)
            nodesDic[nodeName] = currentLoop_node
            nodesList.append(currentLoop_node)
            nodeCount += 1
        }
        
        // if we have a remaining power of 1 at the end, for instance x^7 then multiply last node by src
       
        if(exponent % 2 > 0){
            let currentLoop_inputs : [MTLFunctionStitchingNode] = [
                currentLoopNodes.last!,
                inputs[0],
                srcA
            ]
            let currentLoop_node = MTLFunctionStitchingFunctionNode(name: "multiply", arguments: currentLoop_inputs, controlDependencies: [])
            let nodeName = "powerNode" + String(callCount + nodeCount + nodeNameOffset)
            finalNodeName = nodeName
            nodesDic[nodeName] = currentLoop_node
            nodesList.append(currentLoop_node)
        }
        
        equation.insert(finalNodeName, at: current_index - 1)
        equation.removeSubrange(current_index...current_index+2)
        

        if(equation.count > 1){
            createNodes(postFix: equation, nodesList: &nodesList, nodesDic: &nodesDic, callCount: callCount + 1, nodeNameOffset: nodeCount)
        }
        
        
    }
    
    else{
        let functionName = operators[op]!
        print("function Name is : \(functionName)")
        let node = MTLFunctionStitchingFunctionNode(name: functionName, arguments: inputs, controlDependencies: [])
        nodesList.append(node)
        let nodeName = "Node" + String(callCount + nodeNameOffset)
        nodesDic[nodeName] = node
            
            // now remove the first three
        if(functionName.contains("divide_")){
            equation.insert(nodeName, at: current_index - 1)
            equation.removeSubrange(current_index...current_index+2)
        }
        else if(functionName.contains("_a")){
            equation.insert(nodeName, at: current_index - 1)
            equation.removeSubrange(current_index...current_index+1)
        }
        else{
            equation.insert(nodeName, at: current_index - 2)
            equation.removeSubrange(current_index - 1...current_index + 1)
        }
        print("new Equation is :\(equation)")
       
        if(equation.count > 1){
            createNodes(postFix: equation, nodesList: &nodesList, nodesDic: &nodesDic, callCount: callCount + 1,nodeNameOffset: 1)
        }
    }
    
}




func createStitchedFunction(device : MTLDevice, library : MTLLibrary, inFix : String) -> MTLLinkedFunctions {
    
    var stitchFunctions = [
        library.makeFunction(name: "add")!,
        library.makeFunction(name: "minus")!,
        library.makeFunction(name: "passFirstVariableThrough")!,
        library.makeFunction(name: "times2")!,
        library.makeFunction(name: "square")!,
        library.makeFunction(name: "divide")!,
        library.makeFunction(name: "multiply")!,
        library.makeFunction(name: "multiply_abc")!,
        library.makeFunction(name: "sin_a")!,
        library.makeFunction(name : "cos_a")!,
        library.makeFunction(name : "tan_a")!
    ]
    
    for i in 2...9 {
        let functionName = "divide_" + String(i)
        stitchFunctions.append(library.makeFunction(name: functionName)!)
    }
    
    var nodesList = [MTLFunctionStitchingNode]()
    var nodesDic = [String : MTLFunctionStitchingFunctionNode]()
    let postFix = returnPostFix(inFix: inFix)
    createNodes(postFix: postFix, nodesList: &nodesList, nodesDic: &nodesDic, callCount: 0, nodeNameOffset: 0)
    let graph = MTLFunctionStitchingGraph(functionName: "final", nodes: nodesList as! [MTLFunctionStitchingFunctionNode], outputNode: nodesList.last! as! MTLFunctionStitchingFunctionNode, attributes: [])
    
    let stitchedDescriptor = MTLStitchedLibraryDescriptor()
    stitchedDescriptor.functions = stitchFunctions
    stitchedDescriptor.functionGraphs = [graph]
    
    let stitchedLibrary = try! device.makeLibrary(stitchedDescriptor: stitchedDescriptor)
    let stitchedFunction = stitchedLibrary.makeFunction(name: "final")!
    

    let visibleFunction = MTLLinkedFunctions()
    visibleFunction.functions = [stitchedFunction]
    return visibleFunction
}







extension Dictionary where Value: Comparable {
    func someKey(forValue val: Value) -> Key? {
        return first(where: { $1 > val })?.key
    }
}























func extractPlaceHolderStringFromEquation(inFix : inout String) {
    let regex0 = try! NSRegularExpression(pattern: "f\\(x,y,z\\)\\s\\=\\s")
    let regex1 = try! NSRegularExpression(pattern: "f(\\(x,y\\))\\s\\=\\s")
    let regexes = [regex0,regex1]
    var nString = inFix as NSString
    for reg in regexes {
        let matches = reg.matches(in: inFix, range: NSRange(location: 0, length: inFix.count))
        if let m = matches.first{
            let current_match = nString.substring(with: m.range)
            let startIndex = inFix.index(inFix.startIndex, offsetBy: m.range.lowerBound)
            let endIndex = inFix.index(inFix.startIndex, offsetBy: m.range.upperBound)
            inFix.removeSubrange(startIndex..<endIndex)
            break
        }
    }
  
    

}


func extractConstantFromEquation(inFix : inout String) -> [String] {

    var newEquation = inFix
    let regex = try! NSRegularExpression(pattern: "((\\-|\\+)\\s?([0-9]\\.[0-9]|[0-9]))(?!(z|x|y))")
    var nString = newEquation as NSString
    var matches = regex.matches(in: newEquation, range: NSRange(location: 0, length: newEquation.count))
    var constants = [String]()
    while(!matches.isEmpty){
        let m = matches[0]
        let current_match = nString.substring(with: m.range)
        var current_constant = current_match
        current_constant.removeAll(where: {$0 == " "})
        print("current match is :\(current_constant)")
        constants.append(current_constant)
        let startIndex = newEquation.index(newEquation.startIndex, offsetBy: m.range.lowerBound)
        let endIndex = newEquation.index(newEquation.startIndex, offsetBy: m.range.upperBound)
        newEquation.removeSubrange(startIndex..<endIndex)
        // update matches
        matches = regex.matches(in: newEquation, range: NSRange(location: 0, length: newEquation.count))
        nString = newEquation as NSString
    }
    inFix = newEquation
    
    print("new Equation is : \(inFix)")
    print("constant extracted is \(constants)")
    return constants
}






class Renderer : NSObject, MTKViewDelegate {
    var keyInputs : [UInt16 : Float] = [KeyCodes.a : 0, KeyCodes.d : 0, KeyCodes.s : 0, KeyCodes.w : 0]
  
    var fps : Int = 0
    let frameSephamore = DispatchSemaphore(value: 3)
    let device : MTLDevice
    let commandQueue : MTLCommandQueue
    let library : MTLLibrary
   
    let depthStencilState : MTLDepthStencilState
    
    var projectionMatrix = simd_float4x4(bounds: simd_float3(10,10,10), near: 0.1, far: 100)
    var projectionMatrix1 = simd_float4x4(fovRadians: 3.14/2, aspectRatio: 1, near: 0.1, far: 100)
    var viewMatrix = simd_float4x4(eye: simd_float3(0,0,15), center: simd_float3(0,0,-1), up: simd_float3(0,1,0))
    let frameTransformBuffer : MTLBuffer
    let camera : Camera
    
    // gpu culling stuff here
    
    
    
    
    
    // gpu culling test 2
    
   
    
   
    var stitchedPipeline : MTLComputePipelineState?
    let outputBuffer : MTLBuffer
   
    
    var quadrantSigns = [simd_float2(1,1),simd_float2(-1,-1),simd_float2(1,-1),simd_float2(-1,1)]
    
    let quadrantSignsBuffer : MTLBuffer
    
    
    var newPointSurfaceEquationEntered = false
    var pointSurfaceEquation : String?
    var newIsoSurfaceEquationEntered = false
    var isoSurfaceEquation : String?
    
    
    
    
    
    
    var drawPointMeshFor2DVariableFunction : MTLRenderPipelineState?
    var triangulate2VariableFunction : MTLRenderPipelineState?
    var drawIsoSurfaceTriangulatedPipeline : MTLRenderPipelineState?

    
    var equationConstant : Float = 0
    
    var textureLayersColours = [MTLTexture]()
    var textureLayersDepth = [MTLTexture]()
    let numberOfIsoLevels = 3
    
    let blendingPipeline : MTLRenderPipelineState
    
    var initialIsoColours : [simd_float4] = [simd_float4(1,0,0,1),simd_float4(0,1,0,1),simd_float4(0,0,1,1)]
    var isoLevels = [Float]()
    var isoColours : [simd_float4] = [simd_float4(1,0,0,1),simd_float4(0,1,0,1),simd_float4(0,0,1,1)]
    
    let textureLayersColoursBuffer : MTLBuffer
    let textureLayersDepthBuffer : MTLBuffer
    var globalFillMode = MTLTriangleFillMode.fill
    var globalResolution : Int = 100
    var globalIsTriangulationON = true
    var globalPointSizeOffset : Float = 0
    var globalGridMin : Float = -4
    var gridLength : Float {
        return abs(2 * globalGridMin)
    }
    var voxelLength : Float {
        return gridLength / Float(globalResolution)
    }
    var voxelHalfLength : Float {
        return (0.5 * voxelLength)
    }

    
    init?(mtkView: MTKView) {
        
        
        print("new equation : \(newIsoSurfaceEquationEntered)")
        device = mtkView.device!
        commandQueue = device.makeCommandQueue()!
        library = device.makeDefaultLibrary()!
        mtkView.colorPixelFormat = .rgba8Unorm
        mtkView.depthStencilPixelFormat = .depth32Float
        mtkView.preferredFramesPerSecond = 120
        mtkView.drawableSize = CGSize(width: 800, height: 800)
        mtkView.autoResizeDrawable = false
        
        
        let depthLayerDC = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .r16Float, width: 800, height: 800, mipmapped: false)
        depthLayerDC.usage = [.renderTarget,.shaderRead]
        depthLayerDC.storageMode = .private
        let colourLayerDC = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm, width: 800, height: 800, mipmapped: false)
        colourLayerDC.usage = [.renderTarget,.shaderRead]
        colourLayerDC.storageMode = .private
        for i in 0..<numberOfIsoLevels {
            textureLayersDepth.append(device.makeTexture(descriptor: depthLayerDC)!)
            textureLayersColours.append(device.makeTexture(descriptor: colourLayerDC)!)
        }
        
        textureLayersColoursBuffer = device.makeBuffer(length: MemoryLayout<TextureBuffer>.stride * 3)!
        textureLayersDepthBuffer = device.makeBuffer(length: MemoryLayout<TextureBuffer>.stride * 3)!
        
        let ptrToDepthTextures = textureLayersDepthBuffer.contents().bindMemory(to: TextureBuffer.self, capacity: 3)
        let ptrToColourTextures = textureLayersColoursBuffer.contents().bindMemory(to: TextureBuffer.self, capacity: 3)
        for i in 0..<numberOfIsoLevels {
            (ptrToDepthTextures + i).pointee.texture = textureLayersDepth[i].gpuResourceID._impl
            (ptrToColourTextures + i).pointee.texture = textureLayersColours[i].gpuResourceID._impl
        }
        
        let point = simd_float4(0,0,1,1)
        let pv = projectionMatrix1 * viewMatrix
        var p = pv * point
        p /= p.w
        print("transformed point is : \(p)")
        
        camera = Camera(for: mtkView, eye: simd_float3(0,0,5), centre: simd_float3(0,0,-1))
        
        let depthStencilDC = MTLDepthStencilDescriptor()
        depthStencilDC.depthCompareFunction = .lessEqual
        depthStencilDC.isDepthWriteEnabled = true
        depthStencilState = device.makeDepthStencilState(descriptor: depthStencilDC)!
        
        var temp = [projectionMatrix1,viewMatrix]
        frameTransformBuffer = device.makeBuffer(bytes: temp, length: MemoryLayout<simd_float4x4>.stride * 2 * 3)!
        
        
        
    
        
        
        
        
        
        outputBuffer = device.makeBuffer(length: MemoryLayout<Float>.stride)!
        
        
       
        quadrantSignsBuffer = device.makeBuffer(bytes: quadrantSigns, length: MemoryLayout<simd_float2>.stride * 4)!
        
        
        let blendingPipelineDC = MTLRenderPipelineDescriptor()
        blendingPipelineDC.vertexFunction = library.makeFunction(name: "isoLevel_transparency_vertex_shader")!
        blendingPipelineDC.fragmentFunction = library.makeFunction(name: "isoLevel_transparency_fragment_shader")
        blendingPipelineDC.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat
        blendingPipelineDC.depthAttachmentPixelFormat = .invalid
        
        do {
            blendingPipeline = try device.makeRenderPipelineState(descriptor: blendingPipelineDC)
        }
        catch {
            print(error)
            return nil
        }
        
        
        
     
        
        
        
    }
    
    
    

    // mtkView will automatically call this function
    // whenever it wants new content to be rendered.
    func draw(in view: MTKView) {
        
        var voxelsPerAxis = globalResolution
        var minGrid = simd_float3(repeating: globalGridMin)
        var voxelLength = self.voxelLength
        var voxelHalfLength = self.voxelHalfLength
        var frameIndex = UInt32(fps % 3)
        frameSephamore.wait()
        var ptrToFrameTransformBuffer = frameTransformBuffer.contents().advanced(by: MemoryLayout<simd_float4x4>.stride * 2 * Int(frameIndex)).bindMemory(to: simd_float4x4.self, capacity: 2)
        (ptrToFrameTransformBuffer + 0).pointee = projectionMatrix1
        (ptrToFrameTransformBuffer + 1).pointee = camera.cameraMatrix
        
        guard let commandBuffer = commandQueue.makeCommandBuffer() else {return}
        commandBuffer.addCompletedHandler(){[self] _ in
            frameSephamore.signal()
        }
        
        
        
        
        if(newPointSurfaceEquationEntered){
            print("new equation is true : \(newPointSurfaceEquationEntered)")
            print("equation is : \(isoSurfaceEquation)")
            if var eq = self.pointSurfaceEquation, eq != "" {
                // extract constant
                extractPlaceHolderStringFromEquation(inFix: &eq)
                let constants = extractConstantFromEquation(inFix: &eq)
                for c in constants {
                    equationConstant += (c as NSString).floatValue
                }
                //equationConstant = (constant as NSString).floatValue
                print("equation constant is :\(equationConstant)")
                //let postFix = postToInFix(input: eq)
                let stitchedFunction = createStitchedFunction(device: device, library: library, inFix: eq)
                
                let isoSurfacePipelineDC = MTLMeshRenderPipelineDescriptor()
                isoSurfacePipelineDC.fragmentFunction = library.makeFunction(name: "fragment_shader_iso_surface")
                isoSurfacePipelineDC.objectFunction = library.makeFunction(name: "object_shader_iso_surface")
                isoSurfacePipelineDC.objectLinkedFunctions = stitchedFunction
                isoSurfacePipelineDC.meshFunction = library.makeFunction(name: "mesh_shader_iso_surface")
                
                isoSurfacePipelineDC.depthAttachmentPixelFormat = view.depthStencilPixelFormat
                isoSurfacePipelineDC.colorAttachments[0].pixelFormat = view.colorPixelFormat
                
                isoSurfacePipelineDC.maxTotalThreadgroupsPerMeshGrid = 900
                isoSurfacePipelineDC.maxTotalThreadsPerMeshThreadgroup = 1
                isoSurfacePipelineDC.maxTotalThreadsPerObjectThreadgroup = 900
                
                do {
                    drawPointMeshFor2DVariableFunction = try device.makeRenderPipelineState(descriptor: isoSurfacePipelineDC, options: []).0
                }
                
                catch {
                    print(error)
                }
                
                
                
                let triangulate2VariableFunctionPipelineDC = MTLMeshRenderPipelineDescriptor()
                triangulate2VariableFunctionPipelineDC.fragmentFunction = library.makeFunction(name: "fragment_shader_iso_surface")
                triangulate2VariableFunctionPipelineDC.objectFunction = library.makeFunction(name: "object_shader_2d_surface_triangulated")!
                triangulate2VariableFunctionPipelineDC.objectLinkedFunctions = stitchedFunction
                triangulate2VariableFunctionPipelineDC.meshFunction = library.makeFunction(name: "mesh_shader_iso_surface_triangulated")!
                triangulate2VariableFunctionPipelineDC.colorAttachments[0].pixelFormat = view.colorPixelFormat
                triangulate2VariableFunctionPipelineDC.depthAttachmentPixelFormat = view.depthStencilPixelFormat
                triangulate2VariableFunctionPipelineDC.maxTotalThreadsPerObjectThreadgroup = 1
                triangulate2VariableFunctionPipelineDC.maxTotalThreadsPerMeshThreadgroup = 1
                triangulate2VariableFunctionPipelineDC.maxTotalThreadgroupsPerMeshGrid = 5
                
                do {
                    triangulate2VariableFunction = try device.makeRenderPipelineState(descriptor: triangulate2VariableFunctionPipelineDC, options: []).0
                }
                
                catch {
                    print(error)
                }
                
                newPointSurfaceEquationEntered = false
                
            }
        }
            
            
        if(newIsoSurfaceEquationEntered){
            isoLevels.removeAll()
            isoColours = initialIsoColours
            equationConstant = 0
            if var eq = self.isoSurfaceEquation, eq != "" {
                    // extract constant
                extractPlaceHolderStringFromEquation(inFix: &eq)
                let constants = extractConstantFromEquation(inFix: &eq)
                for c in constants {
                    equationConstant += (c as NSString).floatValue
                }
                    //equationConstant = (constant as NSString).floatValue
                    //let postFix = postToInFix(input: eq)
                let stitchedFunction = createStitchedFunction(device: device, library: library, inFix: eq)
                    
                let drawIsoSurfaceTriangulatedDC = MTLMeshRenderPipelineDescriptor()
                drawIsoSurfaceTriangulatedDC.fragmentFunction = library.makeFunction(name: "fragment_shader_iso_surface")
                drawIsoSurfaceTriangulatedDC.objectFunction = library.makeFunction(name: "object_shader_iso_surface_triangulated")!
                drawIsoSurfaceTriangulatedDC.objectLinkedFunctions = stitchedFunction
                drawIsoSurfaceTriangulatedDC.meshFunction = library.makeFunction(name: "mesh_shader_iso_surface_triangulated")!
                drawIsoSurfaceTriangulatedDC.colorAttachments[0].pixelFormat = view.colorPixelFormat
                drawIsoSurfaceTriangulatedDC.colorAttachments[1].pixelFormat = .r16Float
                drawIsoSurfaceTriangulatedDC.depthAttachmentPixelFormat = view.depthStencilPixelFormat
                drawIsoSurfaceTriangulatedDC.maxTotalThreadsPerObjectThreadgroup = 1
                drawIsoSurfaceTriangulatedDC.maxTotalThreadsPerMeshThreadgroup = 1
                drawIsoSurfaceTriangulatedDC.maxTotalThreadgroupsPerMeshGrid = 5
                    
                do {
                    drawIsoSurfaceTriangulatedPipeline = try device.makeRenderPipelineState(descriptor: drawIsoSurfaceTriangulatedDC, options: []).0
                }
                    
                catch {
                    print(error)
                }
                    
                    newIsoSurfaceEquationEntered = false
                }

            }
                    
                
                
            
        if let triangulate2VFunction = triangulate2VariableFunction, globalIsTriangulationON {
            let renderPass = MTLRenderPassDescriptor()
            renderPass.colorAttachments[0].clearColor = MTLClearColor(red: 1, green: 1, blue: 1, alpha: 1)
            renderPass.depthAttachment.clearDepth = 1
            renderPass.colorAttachments[0].storeAction = .store
            renderPass.colorAttachments[0].loadAction = .clear
            renderPass.depthAttachment.loadAction = .clear
            renderPass.colorAttachments[0].texture = view.currentDrawable!.texture
            renderPass.depthAttachment.texture = view.depthStencilTexture
            
            guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPass) else {return}
            renderEncoder.setRenderPipelineState(triangulate2VFunction)
            renderEncoder.setTriangleFillMode(globalFillMode)
            renderEncoder.setObjectBuffer(frameTransformBuffer, offset: MemoryLayout<simd_float4x4>.stride * 2 * Int(frameIndex), index: 0)
            renderEncoder.setObjectBytes(&frameIndex, length: MemoryLayout<UInt32>.stride, index: 1)
            renderEncoder.setObjectBytes(&minGrid, length: MemoryLayout<simd_float3>.stride * 1, index: 2)
            renderEncoder.setObjectBytes(&voxelHalfLength, length: MemoryLayout<Float>.stride, index: 3)
            renderEncoder.setObjectBytes(&voxelLength, length: MemoryLayout<Float>.stride, index: 4)
            renderEncoder.setObjectBytes(&equationConstant, length: MemoryLayout<Float>.stride, index: 5)
            var colour = isoColours[0]
            renderEncoder.setMeshBytes(&colour, length: MemoryLayout<simd_float4>.stride, index: 0)
            renderEncoder.drawMeshThreadgroups(MTLSize(width: voxelsPerAxis, height: voxelsPerAxis, depth: voxelsPerAxis), threadsPerObjectThreadgroup: MTLSize(width: 1, height: 1, depth: 1), threadsPerMeshThreadgroup: MTLSize(width: 1, height: 1, depth: 1))
            renderEncoder.endEncoding()
        }
            
            
            
            
        if let pointSurfacePipeline = drawPointMeshFor2DVariableFunction {
            let renderPass = MTLRenderPassDescriptor()
            renderPass.colorAttachments[0].clearColor = MTLClearColor(red: 1, green: 1, blue: 1, alpha: 1)
            renderPass.colorAttachments[0].loadAction = .load
            renderPass.colorAttachments[0].storeAction = .store
            renderPass.depthAttachment.clearDepth = 1
            renderPass.depthAttachment.loadAction = .clear
            renderPass.depthAttachment.storeAction = .store
            renderPass.colorAttachments[0].texture = view.currentDrawable!.texture
            renderPass.depthAttachment.texture = view.depthStencilTexture
            guard let isoSurfaceEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPass) else {return}
            isoSurfaceEncoder.setRenderPipelineState(pointSurfacePipeline)
            isoSurfaceEncoder.setObjectBuffer(frameTransformBuffer, offset: MemoryLayout<simd_float4x4>.stride * 2 * Int(frameIndex), index: 0)
            isoSurfaceEncoder.setObjectBytes(&frameIndex, length: MemoryLayout<UInt32>.stride, index: 1)
            
            isoSurfaceEncoder.setObjectBytes(&minGrid, length: MemoryLayout<simd_float3>.stride * 1, index: 2)
            isoSurfaceEncoder.setObjectBytes(&voxelHalfLength, length: MemoryLayout<Float>.stride, index: 3)
            isoSurfaceEncoder.setObjectBytes(&voxelLength, length: MemoryLayout<Float>.stride, index: 4)
            isoSurfaceEncoder.setObjectBytes(&equationConstant, length: MemoryLayout<Float>.stride, index: 5)
            isoSurfaceEncoder.setObjectBytes(&globalPointSizeOffset, length: MemoryLayout<Float>.stride, index: 6)
            var colour = isoColours[1]
            isoSurfaceEncoder.setMeshBytes(&colour, length: MemoryLayout<simd_float4>.stride, index: 0)
            isoSurfaceEncoder.drawMeshThreadgroups(MTLSize(width: voxelsPerAxis, height: voxelsPerAxis, depth: 1), threadsPerObjectThreadgroup: MTLSize(width: 1, height: 1, depth: 1), threadsPerMeshThreadgroup: MTLSize(width: 1, height: 1, depth: 1))
            isoSurfaceEncoder.endEncoding()
                
            }
        
 
  
        if let triangulatedPipeline = drawIsoSurfaceTriangulatedPipeline {
            
            var textureIndex = 0
            for var (iso,colour) in zip(isoLevels, isoColours) {
                let renderPass = MTLRenderPassDescriptor()
                renderPass.colorAttachments[0].clearColor = MTLClearColor(red: 1, green: 1, blue: 1, alpha: 1)
                renderPass.colorAttachments[1].clearColor = MTLClearColor(red: 1, green: 1, blue: 1, alpha: 1)
                renderPass.colorAttachments[0].loadAction = .clear
                renderPass.colorAttachments[0].storeAction = .store
                renderPass.colorAttachments[1].loadAction = .clear
                renderPass.colorAttachments[1].storeAction = .store
                renderPass.depthAttachment.clearDepth = 1
                renderPass.depthAttachment.loadAction = .clear
                renderPass.depthAttachment.storeAction = .store
                renderPass.colorAttachments[0].texture = textureLayersColours[textureIndex]
                renderPass.colorAttachments[1].texture = textureLayersDepth[textureIndex]
                renderPass.depthAttachment.texture = view.depthStencilTexture
                textureIndex += 1
                guard let isoSurfaceEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPass) else {return}
                
                isoSurfaceEncoder.setRenderPipelineState(triangulatedPipeline)
                isoSurfaceEncoder.setTriangleFillMode(globalFillMode)
                
                isoSurfaceEncoder.setObjectBuffer(frameTransformBuffer, offset: MemoryLayout<simd_float4x4>.stride * 2 * (fps % 3), index: 0)
                isoSurfaceEncoder.setObjectBytes(&frameIndex, length: MemoryLayout<UInt32>.stride, index: 1)
                isoSurfaceEncoder.setObjectBytes(&minGrid, length: MemoryLayout<simd_float3>.stride * 2, index: 2)
                isoSurfaceEncoder.setObjectBytes(&voxelHalfLength, length: MemoryLayout<Float>.stride, index: 3)
                isoSurfaceEncoder.setObjectBytes(&voxelLength, length: MemoryLayout<Float>.stride, index: 4)
                isoSurfaceEncoder.setObjectBytes(&equationConstant, length: MemoryLayout<Float>.stride, index: 5)
                isoSurfaceEncoder.setObjectBytes(&iso, length: MemoryLayout<Float>.stride, index: 6)
                isoSurfaceEncoder.setMeshBytes(&colour, length: MemoryLayout<simd_float4>.stride, index: 0)
                isoSurfaceEncoder.drawMeshThreadgroups(MTLSize(width: voxelsPerAxis, height: voxelsPerAxis, depth: voxelsPerAxis), threadsPerObjectThreadgroup: MTLSize(width: 1, height: 1, depth: 1), threadsPerMeshThreadgroup: MTLSize(width: 1, height: 1, depth: 1))
                isoSurfaceEncoder.endEncoding()
            
        }
        
            if(!isoLevels.isEmpty){
                var isoLevelCount = UInt32(isoLevels.count)
                let blendPass = MTLRenderPassDescriptor()
                blendPass.colorAttachments[0].clearColor = MTLClearColor(red: 1, green: 1, blue: 1, alpha: 1)
                blendPass.colorAttachments[0].loadAction = .clear
                blendPass.colorAttachments[0].storeAction = .store
                blendPass.colorAttachments[0].texture = view.currentDrawable!.texture
            
                guard let blendEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: blendPass) else {return}
                blendEncoder.setRenderPipelineState(blendingPipeline)
                blendEncoder.setFragmentBuffer(textureLayersColoursBuffer, offset: 0, index: 0)
                blendEncoder.setFragmentBuffer(textureLayersDepthBuffer, offset: 0, index: 1)
                blendEncoder.setFragmentBytes(&isoLevelCount, length: MemoryLayout<UInt32>.stride, index: 2)
                blendEncoder.useResources(textureLayersDepth, usage: .read, stages: .fragment)
                blendEncoder.useResources(textureLayersColours, usage: .read, stages: .fragment)
                blendEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
                blendEncoder.endEncoding()
            }
        }
            
           
           
        commandBuffer.present(view.currentDrawable!)
        commandBuffer.commit()
        
        
        

        fps += 1

       
    }

    // mtkView will automatically call this function
    // whenever the size of the view changes (such as resizing the window).
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {

    }
}
