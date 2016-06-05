//
//  PlaylistViewController.swift
//  Digg
//
//  Created by Hanawa Takuro on 2016/06/05.
//  Copyright © 2016年 Hanawa Takuro. All rights reserved.
//

import UIKit
import RealmSwift

class PlaylistViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func close(sender: UIBarButtonItem) {

        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension PlaylistViewController: UITableViewDataSource {

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {

        guard let realm = try? Realm() else { return 0 }
        return realm.objects(Playlist).count
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        guard let realm = try? Realm() else { return 0 }
        return realm.objects(Playlist)[section].items.count
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        guard let realm = try? Realm() else { return "" }
        return realm.objects(Playlist)[section].playlistName
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

        guard let realm = try? Realm() else { return cell }
        cell.textLabel?.text = realm.objects(Playlist)[indexPath.section].items[indexPath.row].trackName
        return cell
    }
}
