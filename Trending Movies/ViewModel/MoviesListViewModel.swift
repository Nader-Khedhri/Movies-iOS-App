//
//  MoviesListViewModel.swift
//  Trending Movies
//
//  Created by Nader Khedhri on 17/05/2022.
//

import Foundation
import RxCocoa
import RxSwift
import Alamofire

class MoviesListViewModel {
    
    var loadingBehavior = BehaviorRelay<Bool>(value: false)
    private var isTableHidden = BehaviorRelay<Bool>(value: false)
    private var moviesModelSubject = PublishSubject<[Result]>()
    private var imagesModelSubject = PublishSubject<Images>()
    
    var moviesModelObservable: Observable<[Result]> {
        return moviesModelSubject
    }
    
    var imagesModelObservable: Observable<Images> {
        return imagesModelSubject
    }
    
    var isTableHiddenObservable: Observable<Bool> {
        return isTableHidden.asObservable()
    }
    
    func getMoviesList() {

        let parameters = ["api_key": Constants.apiKey]
        let url = "https://api.themoviedb.org/3/discover/movie"
        let headers: HTTPHeaders = ["Content-Type": "application/json"]
        let encoding = URLEncoding.queryString
        
        loadingBehavior.accept(true)
        APIServices.instance.getData(url: url, method: .get, params: parameters, encoding: encoding, headers: headers) { [weak self](movieModel: MovieModel?, errorModel: BaseErrorModel?, error) in
            guard let self = self else { return }
            self.loadingBehavior.accept(false)
            if let error = error {
                print(error.localizedDescription)
                self.isTableHidden.accept(true)
            } else if let errorModel = errorModel {
                print(errorModel.status_message ?? "")
            } else {
                guard let movieModel = movieModel else { return }
                if movieModel.results.count > 0 {
                    self.moviesModelSubject.onNext(movieModel.results )
                    self.isTableHidden.accept(false)
                } else {
                    self.isTableHidden.accept(true)
                }
            }
        }
    }
    
    func getImage() {

        let parameters = ["api_key": Constants.apiKey]
        let url = "https://api.themoviedb.org/3/configuration"
        let headers: HTTPHeaders = ["Content-Type": "application/json"]
        let encoding = URLEncoding.queryString
        
        APIServices.instance.getData(url: url, method: .get, params: parameters, encoding: encoding, headers: headers) { [weak self](imageModel: ImageModel?, errorModel: BaseErrorModel?, error) in
            guard let self = self else { return }
            if let error = error {
                print(error.localizedDescription)
            } else if let errorModel = errorModel {
                print(errorModel.status_message ?? "")
            } else {
                guard let imageModel = imageModel else { return }
                self.imagesModelSubject.onNext(imageModel.images )
            }
        }
    }
    
}
