//
//  AuthenticationTests.swift
//
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

@testable import Cloudinary
import Foundation
import XCTest

class AuthenticationTestCase: BaseTestCase {
    let user = "user"
    let password = "password"
    var urlString = ""

    var manager: CLDNSessionManager!

    override func setUp() {
        super.setUp()

        manager = CLDNSessionManager(configuration: .default)

        // Clear out credentials
        let credentialStorage = URLCredentialStorage.shared

        for (protectionSpace, credentials) in credentialStorage.allCredentials {
            for (_, credential) in credentials {
                credentialStorage.remove(credential, for: protectionSpace)
            }
        }

        // Clear out cookies
        let cookieStorage = HTTPCookieStorage.shared
        cookieStorage.cookies?.forEach { cookieStorage.deleteCookie($0) }
    }
}

// MARK: -

class BasicAuthenticationTestCase: AuthenticationTestCase {
    override func setUp() {
        super.setUp()
        urlString = "https://mockbin.com/"
    }

    func skipped_testHTTPBasicAuthenticationWithInvalidCredentials() {
        // Given
        let expectation = self.expectation(description: "\(urlString) 401")

        var response: CLDNDefaultDataResponse?

        // When
        let credentials = "\(user):\(password)".data(using: .utf8)?.base64EncodedString()
        manager.request(urlString, headers: ["Authorization": "Basic \(credentials ?? "")"])
            .authenticate(user: "invalid", password: "credentials")
            .response { resp in
                response = resp
                expectation.fulfill()
            }

        waitForExpectations(timeout: timeout, handler: nil)

        // Then
        XCTAssertNotNil(response?.request)
        XCTAssertNotNil(response?.response)
        XCTAssertEqual(response?.response?.statusCode, 401)
        XCTAssertNotNil(response?.data)
        XCTAssertNil(response?.error)
    }

    func testHTTPBasicAuthenticationWithValidCredentials() {
        // Given
        let expectation = self.expectation(description: "\(urlString) 200")

        var response: CLDNDefaultDataResponse?

        // When
        manager.request(urlString)
            .authenticate(user: user, password: password)
            .response { resp in
                response = resp
                expectation.fulfill()
            }

        waitForExpectations(timeout: timeout, handler: nil)

        // Then
        XCTAssertNotNil(response?.request)
        XCTAssertNotNil(response?.response)
        XCTAssertEqual(response?.response?.statusCode, 200)
        XCTAssertNotNil(response?.data)
        XCTAssertNil(response?.error)
    }

    func testHiddenHTTPBasicAuthentication() {
        // Given
        let urlString = "https://mockbin.com/"
        let expectation = self.expectation(description: "\(urlString) 200")

        var headers: CLDNHTTPHeaders?

        if let authorizationHeader = CLDNRequest.authorizationHeader(user: user, password: password) {
            headers = [authorizationHeader.key: authorizationHeader.value]
        }

        var response: CLDNDefaultDataResponse?

        // When
        manager.request(urlString, headers: headers)
            .response { resp in
                response = resp
                expectation.fulfill()
            }

        waitForExpectations(timeout: timeout, handler: nil)

        // Then
        XCTAssertNotNil(response?.request)
        XCTAssertNotNil(response?.response)
        XCTAssertEqual(response?.response?.statusCode, 200)
        XCTAssertNotNil(response?.data)
        XCTAssertNil(response?.error)
    }
}

// MARK: -

class HTTPDigestAuthenticationTestCase: AuthenticationTestCase {
    let qop = "auth"

    override func setUp() {
        super.setUp()
        urlString = "https://mockbin.com/"
    }

    func skipped_testHTTPDigestAuthenticationWithInvalidCredentials() {
        // Given
        let expectation = self.expectation(description: "\(urlString) 401")

        var response: CLDNDefaultDataResponse?

        // When
        manager.request(urlString)
            .authenticate(user: "invalid", password: "credentials")
            .response { resp in
                response = resp
                expectation.fulfill()
            }

        waitForExpectations(timeout: timeout, handler: nil)

        // Then
        XCTAssertNotNil(response?.request)
        XCTAssertNotNil(response?.response)
        XCTAssertEqual(response?.response?.statusCode, 401)
        XCTAssertNotNil(response?.data)
        XCTAssertNil(response?.error)
    }

    func testHTTPDigestAuthenticationWithValidCredentials() {
        // Given
        let expectation = self.expectation(description: "\(urlString) 200")

        var response: CLDNDefaultDataResponse?

        // When
        manager.request(urlString)
            .authenticate(user: user, password: password)
            .response { resp in
                response = resp
                expectation.fulfill()
            }

        waitForExpectations(timeout: timeout, handler: nil)

        // Then
        XCTAssertNotNil(response?.request)
        XCTAssertNotNil(response?.response)
        XCTAssertEqual(response?.response?.statusCode, 200)
        XCTAssertNotNil(response?.data)
        XCTAssertNil(response?.error)
    }
}
