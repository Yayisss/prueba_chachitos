class variables {
  int total;

  variables({
  this.total
  });

  factory variables.fromJson(Map<String, dynamic> json) {
    return variables(
        total: json['total'] as int
    );
  }
}