import XCTest
@testable import VolumeSlider

final class VolumeSliderTests: XCTestCase, VolumeSliderDelegate {
    func didChange(volume: CGFloat) {
        self.recognizedVolume = volume
    }
    
    var slider : VolumeSliderView!
    var recognizedVolume : CGFloat?
    
    override func setUp() {
        self.slider = VolumeSliderView(frame: CGRect(origin: .zero, size: CGSize(width: 65, height: 150)))
        self.slider.delegate = self
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testSetVolume() {
        self.slider.updateLevel(0.5)
        XCTAssertTrue(recognizedVolume! == 0.5)
        
        self.slider.updateLevel(0)
        XCTAssertTrue(recognizedVolume! == 0)
        
        self.slider.updateLevel(1)
        XCTAssertTrue(recognizedVolume! == 1)
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    static var allTests = [
        ("testSetVolume", testSetVolume),
    ]
}
