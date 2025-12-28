package com.devops.ecommerce.product;

public class Product {

    private String name;
    private int price;
    private String image;

    public Product(String name, int price, String image) {
        this.name = name;
        this.price = price;
        this.image = image;
    }

    public String getName() {
        return name;
    }

    public int getPrice() {
        return price;
    }

    public String getImage() {
        return image;
    }
}
