//
//  ViewController.swift
//  bare
//
//  Created by Sina Dashtebozorgy on 24/01/2024.
//

import Cocoa
import Metal
import MetalKit


class camera_timer {
    var timer : Timer? = nil
    let key : UInt16
    var increment : Float = Float(1)/120
    let direction : simd_float3
    let interval : Double = Double(1)/120
    init(key : UInt16){
        self.key = key
        switch key {
        case KeyCodes.w:
            self.direction = increment * simd_float3(0,0,1)
            break
        case KeyCodes.s:
            self.direction = increment * simd_float3(0,0,-1)
            break
        case KeyCodes.a:
            self.direction = increment * simd_float3(-1,0,0)
            break
        case KeyCodes.d:
            self.direction = increment * simd_float3(1,0,0)
            break
        case KeyCodes.q:
            self.direction = increment * simd_float3(0,1,0)
            break
        case KeyCodes.e:
            self.direction = increment * simd_float3(0,-1,0)
            break
        default:
            self.direction = simd_float3(0)
        }
    }
    
    func moveCamera(camera : Camera){
        if let _ = timer {
           
        }
        else {
            timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true){[self] _ in
                camera.update_eye(with: direction)
            }
        }
        
    }
    func stopCamera(){
        if var timer = timer {
            timer.invalidate()
            self.timer = nil
        }
    }
}

class ViewController: NSViewController {
    
    
    @IBOutlet weak var pointSurfaceTextField: NSTextField!
    @IBOutlet weak var isoSurfaceTextField: NSTextField!
    
    @IBOutlet weak var GridMin: NSTextField!
    @IBOutlet weak var iso2_value: NSTextField!
    @IBOutlet weak var iso1_value: NSTextField!
    @IBOutlet weak var iso0_value: NSTextField!
    
    var textFields : [NSTextField] {
        return [pointSurfaceTextField,isoSurfaceTextField,iso0_value,iso1_value,iso2_value,GridMin]
    }
    //@IBOutlet weak var iso2: NSButtonCell!
    //@IBOutlet weak var iso1: NSButtonCell!
    //@IBOutlet weak var iso0: NSButtonCell!
    @IBOutlet weak var R: NSSlider!
    @IBOutlet weak var A: NSSlider!
    @IBOutlet weak var B: NSSlider!
    @IBOutlet weak var G: NSSlider!
    
    @IBOutlet weak var Resolution: NSSlider!
    @IBOutlet weak var iso2: NSButton!
    @IBOutlet weak var iso1: NSButton!
    @IBOutlet weak var iso0: NSButton!
    
    
    
    @IBAction func adjsutGridMin(_ sender: NSTextField) {
        
        renderer.globalGridMin = sender.floatValue
    }
    
    
    @IBAction func setIsoLevel(_ sender: NSTextField) {
        if(renderer.isoLevels.isEmpty && sender == iso0_value){
            renderer.isoLevels.append(sender.floatValue)
        }
        else if(renderer.isoLevels.count == 1 && sender == iso1_value){
            renderer.isoLevels.append(sender.floatValue)
        }
        else if(renderer.isoLevels.count == 2 && sender == iso2_value){
            renderer.isoLevels.append(sender.floatValue)
        }

        
        else if(renderer.isoLevels.count == 3){
            switch sender {
            case iso0_value:
                renderer.isoLevels[0] = sender.floatValue
                break
            case iso1_value:
                renderer.isoLevels[1] = sender.floatValue
                break
            case iso2_value:
                renderer.isoLevels[2] = sender.floatValue
                break
            default:
                break
            }
        }
            
    }
    @IBAction func ColourPicker(_ sender: NSSlider) {
        if(iso0.state == .on){
            renderer.isoColours[0] = simd_float4(R.floatValue,G.floatValue,B.floatValue,A.floatValue)
        }
        else if(iso1.state == .on){
            renderer.isoColours[1] = simd_float4(R.floatValue,G.floatValue,B.floatValue,A.floatValue)
        }
        else if(iso2.state == .on){
            renderer.isoColours[2] = simd_float4(R.floatValue,G.floatValue,B.floatValue,A.floatValue)
        }
        else if(sender == Resolution){
            renderer.globalResolution = sender.integerValue
        }

    }
    
    @IBAction func selectIsoLevel(_ sender: NSButton) {
        
        switch sender {
        case iso0:
            R.floatValue = renderer.isoColours[0][0]
            G.floatValue = renderer.isoColours[0][1]
            B.floatValue = renderer.isoColours[0][2]
            A.floatValue = renderer.isoColours[0][3]
            break
        case iso1:
            R.floatValue = renderer.isoColours[1][0]
            G.floatValue = renderer.isoColours[1][1]
            B.floatValue = renderer.isoColours[1][2]
            A.floatValue = renderer.isoColours[1][3]
            break
        case iso2:
            R.floatValue = renderer.isoColours[2][0]
            G.floatValue = renderer.isoColours[2][1]
            B.floatValue = renderer.isoColours[2][2]
            A.floatValue = renderer.isoColours[2][3]
            break
        default:
            break
        }
        
    }
    
    @IBAction func readEquation(_ sender: NSTextField) {
        print(sender.stringValue)
        if(sender == isoSurfaceTextField){
            print("isosurface")
            renderer.newIsoSurfaceEquationEntered = true
            renderer.isoSurfaceEquation = sender.stringValue
            renderer.newPointSurfaceEquationEntered = false
            renderer.pointSurfaceEquation = nil
            renderer.drawPointMeshFor2DVariableFunction = nil
        }
        else if(sender == pointSurfaceTextField){
            renderer.newPointSurfaceEquationEntered = true
            renderer.pointSurfaceEquation = sender.stringValue
            renderer.newIsoSurfaceEquationEntered = false
            renderer.isoSurfaceEquation = nil
            renderer.drawIsoSurfaceTriangulatedPipeline = nil
            
        }
    }
    
    
//    @IBAction func readEquation(_ sender: NSTextFieldCell) {
//        renderer.newEquationEntered = true
//        renderer.equation = sender.stringValue
//        
//    }
    
    let validCameraKeys : [UInt16 : camera_timer] = [KeyCodes.w : camera_timer(key: KeyCodes.w), KeyCodes.s : camera_timer(key: KeyCodes.s), KeyCodes.a : camera_timer(key: KeyCodes.a), KeyCodes.d : camera_timer(key: KeyCodes.d), KeyCodes.q : camera_timer(key: KeyCodes.q), KeyCodes.e : camera_timer(key: KeyCodes.e)]
    
    
   

    
    override func mouseUp(with event: NSEvent) {
        
        
        renderer.camera.reset_mouse()
            
        
        

    }
    
    override func mouseDragged(with event: NSEvent) {
        let pos = simd_float2(Float(event.locationInWindow.x),Float(event.locationInWindow.y))
        
        renderer.camera.update_mouse(with: pos)
        
    }
   
    
    
    
     func myKeyDownEvent(with event: NSEvent) -> NSEvent{
         
         if(event.keyCode == KeyCodes.upArrow){
             if(renderer.globalPointSizeOffset < 10){
                 renderer.globalPointSizeOffset += 1
             }
         }
         if(event.keyCode == KeyCodes.downArrow){
             if(renderer.globalPointSizeOffset > 0){
                 renderer.globalPointSizeOffset -= 1
             }
         }
         
         if(event.keyCode == KeyCodes.three){
             renderer.globalIsTriangulationON = true
         }
         if(event.keyCode == KeyCodes.four){
             renderer.globalIsTriangulationON = false
         }
         
         if(event.keyCode == KeyCodes.returnKey){
             for field in textFields {
                 if(field.isEditable && field.isSelectable){
                     field.isEditable = false
                     field.isSelectable = false
                 }
                 else{
                     field.isEditable = true
                     field.isSelectable = true
                 }
             }
         }
        
         if(event.keyCode == KeyCodes.one){
             renderer.globalFillMode = .fill
         }
         if(event.keyCode == KeyCodes.two){
             print("drawing unfilled")
             renderer.globalFillMode = .lines
         }
         
         
         if let timer = validCameraKeys[event.keyCode]{
             timer.moveCamera(camera: renderer.camera)
         }
         
        return event
    }
     func myKeyUpEvent(with event: NSEvent) -> NSEvent{
         if let timer = validCameraKeys[event.keyCode]{
             timer.stopCamera()
         }
        return event
    }
    
    var mtkView : MTKView!
    var renderer : Renderer!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        NSEvent.addLocalMonitorForEvents(matching: NSEvent.EventTypeMask.keyDown, handler: myKeyDownEvent)
        NSEvent.addLocalMonitorForEvents(matching: NSEvent.EventTypeMask.keyUp, handler: myKeyUpEvent)
        guard let mtkViewTemp = self.view as? MTKView else {
            print("View attached to ViewController is not an MTKView!")
            return
        }
        
        mtkView = mtkViewTemp
        
        
        guard let defaultDevide = MTLCreateSystemDefaultDevice() else {
            print("Metal is not supported on this device")
            return
        }

        print("My GPU is: \(defaultDevide)")
        mtkView.device = defaultDevide
        
        guard let tempRenderer = Renderer(mtkView: mtkView) else {
            print("Renderer Failed to initialise")
            return
        }
        renderer = tempRenderer
        mtkView.delegate = renderer
        
        // Do any additional setup after loading the view.
    }

   

}

