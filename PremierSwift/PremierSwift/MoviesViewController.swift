import UIKit
import Kingfisher

class MoviesViewController: UITableViewController {
   
    private let moviesController = MovieListController(session: URLSession.shared)
    
    
    @IBAction func refreshed(_ sender: UIRefreshControl) {
        self.refreshData(sender: sender)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Top Movies", comment: "Top Movies")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 140
        
        self.refreshData(sender: nil)
    }
    
    func refreshData(sender: UIRefreshControl?) {
        moviesController.getConfigAndData(completion: { (result) in
            
            if let sentRefesh = sender {
                sentRefesh.endRefreshing()
            }
            
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
            
            
        }) { (errorReason) in
            DispatchQueue.main.async {
                //show error message
                self.presentError(message: errorReason)
            }
            
        }
    }
    
    func presentError(message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            // Do nothing
        }
        alertController.addAction(cancelAction)
        
        let RetryAction = UIAlertAction(title: "Retry", style: .default) { (action) in
            self.refreshData(sender: nil)
        }
        alertController.addAction(RetryAction)
        self.present(alertController, animated: true) {}
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.moviesController.numberOfMovies()
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if let kfCell = cell as? MoviesTableViewCell {
            kfCell.didEndDisplaying()
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let movie = self.moviesController.movieAtindexPath(indexPath: indexPath)
       
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "moviesCell", for: indexPath) as! MoviesTableViewCell

        cell.titleLabel!.text = movie?.title
        cell.descriptionLabel!.text = movie?.description
        
        cell.setImage(urlString: (movie?.posterURLString)!)
        
        
        return cell
    }
}

