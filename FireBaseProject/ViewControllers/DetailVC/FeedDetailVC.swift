

import UIKit

class FeedDetailVC: UIViewController {
  
    lazy var titleLabel:UILabel = {
          
          let rl = UILabel(font: UIFont(name: "Courier-Bold", size: 36.0)!)
          return rl
      }()
      
      lazy var dateLabel:UILabel = {
          
          let rl = UILabel(font: UIFont(name: "Courier-Bold", size: 24.0)!)
          return rl
      }()
      
      lazy var userName:UILabel = {
          
          let rl = UILabel(font: UIFont(name: "Courier-Bold", size: 24.0)!)
        rl.textColor = #colorLiteral(red: 0.2601475716, green: 0.2609100342, blue: 0.9169666171, alpha: 1)
          return rl
      }()
     
      
      lazy var bodyTextView:UITextView = {
          let atv = UITextView()
          atv.adjustsFontForContentSizeCategory = true
          atv.textAlignment = .center
          atv.textColor = #colorLiteral(red: 0.2601475716, green: 0.2609100342, blue: 0.9169666171, alpha: 1)
          atv.backgroundColor = .clear
          atv.font = UIFont(name: "Courier-Bold", size: 24.0)
          atv.isEditable = false
          atv.isSelectable = true
          return atv
      }()
      
      lazy var feedImageView:UIImageView = {
          let vIv = UIImageView()
          vIv.contentMode = .scaleAspectFit
          vIv.tintColor = .black
          return vIv
      }()
    
    lazy var viewArray = [self.titleLabel,self.feedImageView,self.dateLabel,self.userName,self.bodyTextView]
    
    var post:Post!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addDetailsToSubViews()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        CustomLayer.shared.setGradientBackground(colorTop: .white, colorBottom: .lightGray, newView: view)
        addSubviewsToView()
        configureTitleConstraints()
        configurefeedImageViewConstraints()
        configureDateLabel()
        configureUserNameConstraints()
        configureTextViewConstraints()
        // Do any additional setup after loading the view.
    }
    
    private func addDetailsToSubViews() {
      //  if post != nil {
        titleLabel.text = post.title
      
        dateLabel.text = currentDate(date: post.dateCreated)
       bodyTextView.text = post.body
        userName.text = "Username: \(post.username)"
        ImageHelper.shared.getImage(urlStr: post.feedImage) { [weak self](result) in
            DispatchQueue.main.async {
            switch result {
            case .failure(let error):
                self?.feedImageView.image = UIImage(systemName: "photo")
                print(error)
            case .success(let imageData):
                self?.feedImageView.image = imageData
            }
        }
        }
    }
    
    private func currentDate(date:Date?)->String{
        guard let currentDate = date else {
            return "Date Unavailable"
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a 'on' MM/dd,yyyy"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        return formatter.string(from: currentDate)
    }
    
    private func addSubviewsToView() {
        for newView in viewArray {
            view.addSubview(newView)
            newView.translatesAutoresizingMaskIntoConstraints = false
        }
        }
    private func configureTitleConstraints() {
           NSLayoutConstraint.activate([
               titleLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor,constant: 20),
               titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 10),
               titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant:  -10),
               titleLabel.heightAnchor.constraint(equalToConstant: 50)
           ])
       }
       private func configurefeedImageViewConstraints() {
           NSLayoutConstraint.activate([
               feedImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
               feedImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 10),
               feedImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -10),
               feedImageView.heightAnchor.constraint(equalToConstant: view.frame.height * 0.4)
           ])
           
       }
    
    private func configureUserNameConstraints() {
        NSLayoutConstraint.activate([
            userName.topAnchor.constraint(equalTo: dateLabel.bottomAnchor,constant: 10),
            userName.centerXAnchor.constraint(equalTo: feedImageView.centerXAnchor),
            userName.heightAnchor.constraint(equalToConstant: 50),
            userName.widthAnchor.constraint(equalToConstant: view.frame.width * 0.8)
            
        ])
    }
       private func configureTextViewConstraints() {
           NSLayoutConstraint.activate([
               bodyTextView.topAnchor.constraint(equalTo: userName.bottomAnchor,constant: 20),
               
               
               bodyTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
               bodyTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bodyTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,constant: -10)
           ])
       }
       
       private func configureDateLabel() {
           NSLayoutConstraint.activate([
               dateLabel.topAnchor.constraint(equalTo: feedImageView.bottomAnchor,constant: 10),
               dateLabel.centerXAnchor.constraint(equalTo: feedImageView.centerXAnchor),
               dateLabel.heightAnchor.constraint(equalToConstant: 30)
           ])
       }
       

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
