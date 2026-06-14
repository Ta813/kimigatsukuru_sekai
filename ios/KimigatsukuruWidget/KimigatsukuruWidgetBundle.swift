//
//  KimigatsukuruWidgetBundle.swift
//  KimigatsukuruWidget
//
//  Created by macbook on 2026/06/14.
//

import WidgetKit
import SwiftUI

//@main
struct KimigatsukuruWidgetBundle: WidgetBundle {
    var body: some Widget {
        KimigatsukuruWidget()
        KimigatsukuruWidgetControl()
        KimigatsukuruWidgetLiveActivity()
    }
}
