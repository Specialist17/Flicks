//
//  MoviesVC.swift
//  Flicks
//
//  Created by Fernando on 1/27/16.
//  Copyright © 2016 Fernando. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD
import SwiftyJSON


class MoviesVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var movieTable: UITableView!
    
    var movies: [NSDictionary]?
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        movieTable.dataSource = self
        movieTable.delegate = self
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self.movies, action: "refreshControlAction", forControlEvents: UIControlEvents.ValueChanged)
        movieTable.insertSubview(refreshControl, atIndex: 0)
        
        refreshControlAction()
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movies = movies {
            return movies.count
        }else{
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        
        let movie = movies![indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        let poster_path = movie["poster_path"] as! String
        
        let baseURL = "http://image.tmdb.org/t/p/w500"
        
        let imageUrl = NSURL(string: baseURL + poster_path)
        let imageRequest = NSURLRequest(URL: imageUrl!)
        
        cell.movieImg.setImageWithURLRequest(
            imageRequest,
            placeholderImage: nil,
            success: { (imageRequest, imageResponse, image) -> Void in
                
                if imageResponse != nil {
                    
                    cell.movieImg.alpha = 0.0
                    cell.movieImg.image = image
                    
                    UIImageView.animateWithDuration(0.7, animations: { () -> Void in
                        cell.movieImg.alpha = 1.0
                    })
                } else {
                    
                    cell.movieImg.image = image
                }
            },
            failure: { (imageRequest, imageResponse, error) -> Void in
                print(error)
        })
        
        cell.titleLbl.text = title
        cell.overviewLbl.text = overview
        return cell
    }
    
    func refreshControlAction(){
        
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        let request = NSURLRequest(URL: url!)
        
        let session = NSURLSession(
                configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
                delegate:nil,
                delegateQueue:NSOperationQueue.mainQueue()
            )
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
                completionHandler: { (data, response, error) in
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                    if let data = data {
                        if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                            data, options:[]) as? NSDictionary {
                                //NSLog("response: \(responseDictionary)")
                                
                                self.movies = responseDictionary["results"] as? [NSDictionary]
                                self.movieTable.reloadData()
                                
                                self.refreshControl.endRefreshing()
                                
                        }
                    }
            });
            task.resume()
        
    }
    
}