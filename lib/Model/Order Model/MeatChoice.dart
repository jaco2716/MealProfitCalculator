class MeatChoice {
    String title;
    int price;
    int amount;

    MeatChoice(this.title, this.price, this.amount);

    MeatChoice.clone(MeatChoice meatChoiceCopy) : this(meatChoiceCopy.title, meatChoiceCopy.price, meatChoiceCopy.amount);

    MeatChoice.fromJson(Map<String, dynamic> json)
      : title = json['title'],
       price = json['price'],
       amount = json['amount'];

  Map<String, dynamic> toJson() => {
        'title': title,
        'price': price,
        'amount': amount,
      };
}