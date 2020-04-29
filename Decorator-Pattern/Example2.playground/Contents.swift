import UIKit

// ------------------------------------------------------------------------------------------------------- //
// 3. Post (Real world example)

struct Post: Codable {
    
    var id: Int
    var title: String
    var subtitle: String
}

// Result.swift
enum Result<T> {
    case value(T)
    case error(Error)
}

// Interface
protocol Service {
    func getPost(id: Int, completion: (Result<Post>) -> Void)
    func getPosts(completion: (Result<[Post]>) -> Void)
    func createPost(title: String, subtitle: String, completion: (Result<Post>) -> Void)
}

// Core object
// In Memory
final class DefaultPostService: Service {

    private var id = 0
    private var posts: [Int: Post] = [:]

    func getPost(id: Int, completion: (Result<Post>) -> Void) {

        if let post = posts[id] {
            // The post exists in memory
            completion(.value(post))
        } else {
            let error = NSError(domain: "Network error", code: 1, userInfo: nil) // 404 presumably
            completion(.error(error))
        }
    }
    
    func getPosts(completion: (Result<[Post]>) -> Void) {
        completion(.value(posts.values.compactMap{$0}))
    }
    
    func createPost(title: String, subtitle: String, completion: (Result<Post>) -> Void) {
        let post = Post(id: id, title: title, subtitle: subtitle)
        posts[post.id] = post
        id += 1 // Like a db would autoincrement unique identifiers
        completion(.value(post))
    }
}

// Mock - For displaying posts in the UIViewController with a tableview
class PostsTableViewController /* : UITableViewController */ {
    
//    @IBOutlets  tableView(here)
//
    var posts: [Post] = []
    var postService: Service?
//    --- UIViewController lifecycle ---
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        (tableView inisilization here)
//        loadPost()
//    }
    
    func loadPosts() {
        
        // here we don't care where the post comes from.
        // We only care about the posts which PostService gives
        postService?.getPosts(completion: { [weak self] value in
            switch value {
            case .value(let posts):
                self?.posts = posts
                // simulate tableView reload data
                //self.tableView.reloadData()
            case .error(let error):
                print(error)
                // display Error on alertcontroller
            }
        })
    }
}


// Now We make a concrete 'Service' decorator to perform caching
protocol PostCache {
    func getPost(id: Int) -> Post?
    func getPosts() -> [Post]
    func storePost(post: Post)
    func storePosts(posts: [Post])
}

// Concrete  in-memory PostCache
class DefaultPostCache: PostCache {

    private var postsHolder: [Int: Post] = [:]

    func getPost(id: Int) -> Post? {
        return postsHolder[id]
    }
    
    func getPosts() -> [Post] {
        return postsHolder.values.compactMap{$0}
    }
    
    func storePost(post: Post) {
        postsHolder[post.id] = post
    }
    
    func storePosts(posts: [Post]) {
        self.postsHolder.removeAll() // complex merge here
        for post in posts {
            storePost(post: post)
        }
        
    }
}

// MARK: - Abstract Decorator
protocol ServiceDecorator: Service {
    
    var service: Service { get }
}
extension ServiceDecorator {
    
    // Forward all calls to the service object by default
    
    func getPost(id: Int, completion: (Result<Post>) -> Void) {
        service.getPost(id: id, completion: completion)
    }
    func getPosts(completion: (Result<[Post]>) -> Void) {
        service.getPosts(completion: completion)
    }
    func createPost(title: String, subtitle: String, completion: (Result<Post>) -> Void) {
        service.createPost(title: title, subtitle: subtitle, completion: completion)
    }
}

class ServiceCacheDecorator: ServiceDecorator {
    
    private var cache: PostCache
    var service: Service
    
    init(cache: PostCache, service: Service) {
        
        self.cache = cache
        self.service = service
    }
    
    func getPost(id: Int, completion: (Result<Post>) -> Void) {
        
        guard let cachePost = cache.getPost(id: id) else {
            
            // no post in the cache so go to network and get the post
            return service.getPost(id: id) { result in
                
                // Cache posts from network for next time
                if case .value(let post) = result {
                    cache.storePost(post: post)
                }
                
                // Forward the result
                completion(result)
            }
        }
        // Cache data return
        completion(.value(cachePost))
    }
    
    func getPosts(completion: (Result<[Post]>) -> Void) {
        
        // other check can include timestamp of last server call, hashvalue of data change from server, e-tag etc
        guard cache.getPosts().count == 0 else {
            // hit the network to check for post
            return service.getPosts { result in
                // cache the result
                if case .value(let posts) = result {
                    cache.storePosts(posts: posts)
                }
                // Forward the result
                completion(result)
            }
        }
        // Cache data return
        completion(.value(cache.getPosts()))
    }
    
    func createPost(title: String, subtitle: String, completion: (Result<Post>) -> Void) {
        
        // hit the network to create new post
        service.createPost(title: title, subtitle: subtitle) { result in
            // cache the result
            if case .value(let post) = result {
                cache.storePost(post: post)
            }
            // Forward the result
            completion(result)
        }
    }
}

/*
    We now have a post repo with a mocked out API and an in-memory cache.
 */
// we can use the DefaultPostService by (Core Object in Decorator)
let mockPostAPIService = DefaultPostService()

// we can create the concrete Cache Service
let cache = DefaultPostCache()

// create the service decorator
let service: Service = ServiceCacheDecorator(cache: cache, service: mockPostAPIService)

/*
    Let’s make an HttpService to make our network calls and a UserDefaultsPostCache to persist data between app launches.
 */

// Some abstraction around URLSession
protocol HttpClient {
    func getPost(_ path: String, completion: (Result<Post>) -> Void)
    func getPosts(_ path: String, completion: (Result<[Post]>) -> Void)
    func post(_ path: String, body: [String: Any], completion: (Result<Post>) -> Void)
    // put, delete...
}

class Network: HttpClient {
    
    func getPost(_ path: String, completion: (Result<Post>) -> Void)  {
        
        // URLSession here
        
        // This is simulation
        let post = Post(id: 1, title: "title1", subtitle: "subTitle1")
        let result: Result = Result.value(post)
        
        completion(result)
    }
    
    func getPosts(_ path: String, completion: (Result<[Post]>) -> Void) {
        // URLSession here
        
        // This is simulation
        let posts = [Post(id: 1, title: "title1", subtitle: "subTitle1"),
                     Post(id: 2, title: "title2", subtitle: "subTitle2"),
                     Post(id: 3, title: "title3", subtitle: "subTitle3")
        ]
        let result: Result = Result.value(posts)
        
        completion(result)
    }
    func post(_ path: String, body: [String : Any], completion: (Result<Post>) -> Void) {
        let post = Post(id: 1, title: "title1", subtitle: "subTitle1")
        let result: Result = Result.value(post)
        completion(result)
    }
}

class HttpPostService: Service {

    private let http: HttpClient

    init(http: HttpClient) {
        self.http = http
    }

    func getPost(id: Int, completion: (Result<Post>) -> Void) {
        http.getPost("/posts/\(id)", completion: completion)
    }
    
    func getPosts(completion: (Result<[Post]>) -> Void) {
        http.getPosts("/posts/", completion: completion)
    }

    func createPost(title: String, subtitle: String, completion: (Result<Post>) -> Void) {

        let httpBody: [String: Any] = [
            "title": title,
            "subtitle": subtitle
        ]

        http.post("/posts", body: httpBody, completion: completion)
    }
}

// Cache as UserDefault
class UserDefaultsPostCache: PostCache {
    
    private let defaults: UserDefaults
    private let storageKey: String

    init(defaults: UserDefaults, storageKey: String ) {
        self.defaults = defaults
        self.storageKey = storageKey
    }

    // MARK: - PostCache

    func getPost(id: Int) -> Post? {
        
        let posts = getPosts()
        if let index = posts.firstIndex(where: {$0.id == id}) {
            return posts[index]
        }
        return nil
    }
    
    func getPosts() -> [Post] {
        if let data = defaults.data(forKey: self.storageKey) {
            do {
                let postArray = try JSONDecoder().decode([Post].self, from: data)
                return postArray
            } catch  {
                print(error)
            }
        }
        return []
    }
    
    func storePost(post: Post) {
        
        var posts = getPosts()
        if posts.contains(where: { $0.id == post.id}) {
            // do update here
        } else {
            posts.append(post)
        }
        storePosts(posts: posts)
    }
    
    func storePosts(posts: [Post]) {
        do {
            let data = try JSONEncoder().encode(posts)
            defaults.set(data, forKey: storageKey)
        } catch  {
            print(error)
        }
    }
}

let usrDefaultsCache = UserDefaultsPostCache(defaults: UserDefaults.standard, storageKey: "TestArray")
let network = HttpPostService(http: Network())
let postRepo = ServiceCacheDecorator(cache: usrDefaultsCache, service: network)

