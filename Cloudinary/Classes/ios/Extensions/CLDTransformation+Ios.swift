//
//  CLDTransformation+Ios.swift
//  Cloudinary
//
//  Created on 23/02/2020.
//

import Foundation
import UIKit

extension CLDTransformation
{
    /**
     Deliver the image in the correct device pixel ratio, according to the used device.
     
     - returns:             The same instance of CLDTransformation.
     */
    @discardableResult
    open func setDprAuto() -> Self {
#if os(visionOS)
        let scale = Float(1)
#else
        let scale = Float(UIScreen.main.scale)
#endif
        return setDpr(scale)
    }
}
