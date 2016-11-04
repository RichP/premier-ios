import XCTest
@testable import PremierSwift


class MockSession: URLSession {
    var completionHandler: ((Data?, URLResponse?, Error?) -> Void)?
    
    static var mockResponse: (data: Data?, urlResponse: URLResponse?, error: Error?) = (data: nil, urlResponse: nil, error: nil)
    
    override func dataTask(with url: URL, completionHandler: ((Data?, URLResponse?, Error?) -> Void)?) -> URLSessionDataTask {
        self.completionHandler = completionHandler
        return MockTask(response: MockSession.mockResponse, completionHandler: completionHandler)
    }
    
    class MockTask: URLSessionDataTask {
        typealias Response = (data: Data?, urlResponse: URLResponse?, error: Error?)
        var mockResponse: Response
        let completionHandler: ((Data?, URLResponse?, Error?) -> Void)?
        
        init(response: Response, completionHandler: ((Data?, URLResponse?, Error?) -> Void)?) {
            self.mockResponse = response
            self.completionHandler = completionHandler
        }
        override func resume() {
            completionHandler!(mockResponse.data, mockResponse.urlResponse, mockResponse.error)
        }
    }
}

class MovieListControllerMock : MovieListController {
    
    
    override init(session: URLSession) {
        super.init(session: session)
        
        
        var movie1 = Movie()
        movie1.title = "title1"
        movie1.description = "description1"
        movie1.posterURLString = "http://www.google.com"
        
        var movie2 = Movie()
        movie2.title = "title2"
        movie2.description = "description2"
        movie2.posterURLString = "http://www.google.com"
        
        
        self.movies = [movie1, movie2]
        
    }
}


class PremierSwiftTests: XCTestCase {
    
    let testController = MovieListControllerMock(session: MockSession())
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCount() {
        // This is an example of a functional test case.
        
        let count = testController.numberOfMovies()
        
        XCTAssertTrue(count == 2, "There should be 2 movies")
        
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testIndexInRange() {
        let indexPath = IndexPath(row: 0, section: 0)
        
        let item = testController.movieAtindexPath(indexPath: indexPath)
        
        XCTAssertNotNil(item, "Should have returned an Item")
        
        XCTAssertEqual(item?.title, "title1", "Should return title of first Movie")
        
        XCTAssertEqual(item?.description, "description1", "Should return description of first Movie")
        
    }
    
    func testIndexOutOfBounds() {
        let indexPath = IndexPath(row: 5, section: 0)
        
        let item = testController.movieAtindexPath(indexPath: indexPath)
        
        XCTAssertNil(item, "Should return Nil")
    }
    
    func testNetworkError() {
        MockSession.mockResponse = (data: nil, urlResponse: nil, error: nil)
        
        let testCon = MovieListControllerMock(session: MockSession())
        
        let exp = expectation(description: "Should Fail with network error")
        
        testCon.getConfigAndData(completion: { (Bool) in
                XCTFail()
            }) { (String) in
                XCTAssertEqual(String, "There was A Networking Error.  Please check your Connection", "Should return networking error")
                
                exp.fulfill()
        }
        
        waitForExpectations(timeout: 10) { error in
            // ...
        }
    }
    
    func testParseError() {
        let jsonData = try? JSONSerialization.data(withJSONObject: ["config": "blah"], options: .prettyPrinted)
        
        let urlResponse = HTTPURLResponse(url: URL(string: "https://www.google.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        
        MockSession.mockResponse = (jsonData, urlResponse: urlResponse, error: nil)
        
        
        let testCon = MovieListControllerMock(session: MockSession())
        
        let exp = expectation(description: "Should Fail with parse error")
        
        testCon.getConfigAndData(completion: { (Bool) in
            XCTFail()
            
        }) { (String) in
            XCTAssertEqual(String, "There was An Error parsing the response data", "Should return json parse error")
            
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 10) { error in
            // ...
        }
    }
    
    
    func testGetMoviesSuccess() {
        
        let jsonData = try? JSONSerialization.data(withJSONObject: ["results": [["title": "title1", "overview": "description1", "poster_path": "image.jpg"]]], options: .prettyPrinted)
        let urlResponse = HTTPURLResponse(url: URL(string: "https://www.google.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        
        MockSession.mockResponse = (jsonData, urlResponse: urlResponse, error: nil)
        let testCon = MovieListControllerMock(session: MockSession())
        
        testCon.config = Config()
        testCon.config?.baseURLString = "http://facebook.com"
        testCon.config?.posterSizes = ["w192"]
        
        let exp = expectation(description: "Should Fail with parse error")
        
        testCon.getTopMovies(completion: { (success) in
            XCTAssertTrue(success, "Should return successfully")
            exp.fulfill()
        }) { (String) in
            XCTFail()
            
        }
        
        waitForExpectations(timeout: 10) { error in
            // ...
        }
    }
}
