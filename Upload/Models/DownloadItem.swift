//
//  DownloadItem.swift
//  Upload
//
//  Created by Елена Острожинская on 17.11.2021.
//

import Foundation

struct DownloadItem: Codable {
    var name: String?
    var id: Int?
    var exported: Int?
}

struct DownloadItemWrap: Codable {
    var items: [DownloadItem]?
}

//card =     {
//    id = 1;
//    name = "TEST-CARD";
//    user =         {
//        id = 2;
//        name = "Test User";
//    };
//};
//"created_at" = "2020-10-11T18:39:59.000Z";
//data = "/api/files/13/data";
//exported = 1;
//id = 13;
//name = "test_qr.txt";
//pos =     {
//    id = 1;
//    name = "TEST-POS";
//};
//"updated_at" = "2020-10-11T18:45:51.000Z";
//}
