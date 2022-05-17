//
//  MoviesListViewController.swift
//  Trending Movies
//
//  Created by Nader Khedhri on 17/05/2022.
//

import UIKit
import RxSwift
import RxCocoa
import Alamofire
import AlamofireImage

class MoviesListViewController: UIViewController {

    @IBOutlet weak var moviesContainerView: UIView!
    @IBOutlet weak var moviesTableView: UITableView!
    
    let moviesTableViewCell = "MovieTableViewCell"
    let moviesListViewModel = MoviesListViewModel()
    let disposeBag = DisposeBag()
    var imageURL:String = ""
    var urlFirstPart:String = ""
    let imageCache = NSCache<NSString, UIImage>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        bindToHiddenTable()
        subscribeToLoading()
        subscribeToImages()
        subscribeToResponse()
        subscribeToSelection()
        getData()
    }
    
    func setupTableView() {
        self.title = "Trending Movies"
        moviesTableView.register(UINib(nibName: moviesTableViewCell, bundle: nil), forCellReuseIdentifier: moviesTableViewCell)
        moviesTableView.rx.setDelegate(self).disposed(by: disposeBag)
    }
    
    func bindToHiddenTable() {
        moviesListViewModel.isTableHiddenObservable.bind(to: self.moviesContainerView.rx.isHidden).disposed(by: disposeBag)
    }
    
    func subscribeToLoading() {
        moviesListViewModel.loadingBehavior.subscribe(onNext: { (isLoading) in
            if isLoading {
                self.showIndicator(withTitle: "", and: "")
            } else {
                self.hideIndicator()
            }
        }).disposed(by: disposeBag)
    }
    
    func subscribeToImages() {
        moviesListViewModel.imagesModelObservable.subscribe(onNext: { (image) in
            self.urlFirstPart = "\(image.secureBaseURL)\(image.logoSizes[5])"
        }).disposed(by: disposeBag)
    }
    
    func subscribeToResponse() {
        self.moviesListViewModel.moviesModelObservable
            .bind(to: self.moviesTableView
                .rx
                .items(cellIdentifier: moviesTableViewCell,
                       cellType: MovieTableViewCell.self)) { row, product, cell in
                            cell.title?.text = product.title
                            cell.date?.text = String(product.releaseDate.prefix(4))

                
                            self.imageURL = "\(String(describing: self.urlFirstPart))\(product.backdropPath!)"
                            if(self.imageCache.object(forKey: self.imageURL as NSString) != nil){
                                cell.avatar.image = self.imageCache.object(forKey: self.imageURL as NSString)
                            }else{
                                Alamofire.request(self.imageURL).responseImage { (response) in
                                    if let image = response.result.value {
                                        let roundedImage = image.af_imageRounded(withCornerRadius: 5.0)
                                        DispatchQueue.main.async {
                                            self.imageCache.setObject(roundedImage, forKey: self.imageURL as NSString)
                                            cell.avatar.image = roundedImage
                                        }
                                    }
                                }
                            }

        }
        .disposed(by: disposeBag)
    }
    
    func subscribeToSelection() {
        Observable
            .zip(moviesTableView.rx.itemSelected, moviesTableView.rx.modelSelected(Result.self))
            .bind { [weak self] selectedIndex, movie in
                if let movieDetailsViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MovieDetailsViewController") as? MovieDetailsViewController {
                    movieDetailsViewController.idMovie = movie.id
                    movieDetailsViewController.imageUrl = "\(String(describing: self!.urlFirstPart))\(movie.backdropPath!)"
                    self?.present(movieDetailsViewController, animated: true)
                }
            }
        .disposed(by: disposeBag)
    }
    
    func getData() {
        moviesListViewModel.getMoviesList()
        moviesListViewModel.getImage()
    }
    
}

extension MoviesListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 135
    }
}
