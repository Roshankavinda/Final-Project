class Post{
  String title;
  String? description;
  String? imagePath;
  String user;

  Post({required this.title, this.description, this.imagePath, required this.user});

  factory Post.fromJson(Map<String, dynamic> json) => Post(
      title: json['title'],
      user: json['user'],
      imagePath: json['image_path'],
      description: json['description']
  );
}