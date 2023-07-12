import UIKit
import MetalKit
import MetalPerformanceShaders

let vertexData: [Float] = [-1, -1, 0, 1,
                            1, -1, 0, 1,
                           -1,  1, 0, 1,
                            1,  1, 0, 1]

let textureCoordinateData: [Float] = [0, 1,
                                      1, 1,
                                      0, 0,
                                      1, 0]

class ViewController: UIViewController, MTKViewDelegate {

    private let device = MTLCreateSystemDefaultDevice()!
    private var commandQueue: MTLCommandQueue!
    private var texture: MTLTexture!

    @IBOutlet private weak var mtkView: MTKView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupMetal()

        loadTexture()

        mtkView.enableSetNeedsDisplay = true
        mtkView.setNeedsDisplay()
    }

    private func setupMetal() {
        commandQueue = device.makeCommandQueue()

        mtkView.device = device
        mtkView.delegate = self
        mtkView.framebufferOnly = false
    }

    private func loadTexture() {
        let textureLoader = MTKTextureLoader(device: device)
        texture = try! textureLoader.newTexture(
            name: "kerokero",
            scaleFactor: view.contentScaleFactor,
            bundle: nil)

        mtkView.colorPixelFormat = texture.pixelFormat
    }

    // MARK: - MTKViewDelegate

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // nop
    }

    func draw(in view: MTKView) {
        guard MPSSupportsMTLDevice(device) else {
            return
        }

        guard let drawable = view.currentDrawable else {return}

        guard let commandBuffer = commandQueue.makeCommandBuffer() else {fatalError()}

        let blurRadius: Float = 10.0
        let blur = MPSImageGaussianBlur(device: device, sigma: blurRadius)
        blur.encode(commandBuffer: commandBuffer,
                    sourceTexture: texture,
                    destinationTexture: drawable.texture)

        commandBuffer.present(drawable)

        commandBuffer.commit()

        commandBuffer.waitUntilCompleted()
    }

}

