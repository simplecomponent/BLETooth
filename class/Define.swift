//
//  Define.swift
//  BLETooth
//
//  Created by LionPig on 2019/8/30.
//  Copyright © 2019 LionPig. All rights reserved.
//

import Foundation
func ZXDebugPrint<T>(_ debugStr:T,
                     methodName:String = #function,
                     line:Int = #line,
                     file:String = #file)
{
    #if DEBUG
    print("----------------------------\nZXDebug:\(debugStr)\nfrom:\(methodName)\nLine:\(line.description)\nfile:\(file)\n----------------------------\n")
    #else
    #endif
}

func ZXDebugSimplePrint<T>(_ debugStr:T,
                           methodName:String = #function)
{
    #if DEBUG
    print("----------------------------\nZXDebug:\n\(debugStr)\nfrom:\(methodName)\n----------------------------\n")
    #else
    #endif
}
