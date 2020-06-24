//
//  ShockException.swift
//  Shock
//
//  Created by Kurt Höblinger on 01.05.19.
//  Copyright © 2019 Kurt Höblinger. All rights reserved.
//

import Foundation

enum ShockException: Error {
    case DatabaseSaveError
    case DatabaseLoadError
    case DatabaseClearError
    
    case JSONParsingError
    case DownloadError
    case URLCreationError
}
