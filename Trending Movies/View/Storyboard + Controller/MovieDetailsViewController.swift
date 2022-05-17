//
//  MovieDetailsViewController.swift
//  Trending Movies
//
//  Created by Nader Khedhri on 17/05/2022.
//

import UIKit
import RxSwift
import RxCocoa
import Alamofire
import AlamofireImage

class MovieDetailsViewController: UIViewController {

    @IBOutlet weak var movieAvatar: UIImageView!
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var movieReleaseDate: UILabel!
    @IBOutlet weak var movieOverview: UILabel!
    
    let movieDetailsViewModel = MovieDetailsViewModel()
    let disposeBag = DisposeBag()
    var idMovie:Int = 0
    var imageUrl:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Movie Details"
        getData()
        subscribeToMovieDetails()
        subscribeToLoading()
        
        
    }
    
    func getData() {
        movieDetailsViewModel.getMovieDetails(idMovie: idMovie)
    }
    
    func subscribeToMovieDetails() {
        movieDetailsViewModel.movieDetailsModelObservable.subscribe(onNext: { (movie) in
            self.movieTitle.text = movie.originalTitle
            self.movieReleaseDate.text = String(movie.releaseDate.prefix(4))
            self.movieOverview.text = movie.overview
            
            Alamofire.request(self.imageUrl).responseImage { (response) in
                if let image = response.result.value {
                    let roundedImage = image.af_imageRounded(withCornerRadius: 5.0)
                    DispatchQueue.main.async {
                        self.movieAvatar.image = roundedImage
                    }
                }
            }
            
        }).disposed(by: disposeBag)
    }
    
    func subscribeToLoading() {
        movieDetailsViewModel.loadingBehavior.subscribe(onNext: { (isLoading) in
            if isLoading {
                self.showIndicator(withTitle: "", and: "")
            } else {
                self.hideIndicator()
            }
        }).disposed(by: disposeBag)
    }

}
