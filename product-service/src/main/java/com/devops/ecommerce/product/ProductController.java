package com.devops.ecommerce.product;

import java.util.List;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class ProductController {

    @GetMapping("/products")
    public List<Product> getProducts() {
        return List.of(
            new Product("Laptop", 70000, "laptop.jpg"),
            new Product("Mobile", 30000, "mobile.jpg"),
            new Product("Headphones", 3000, "headphones.jpg")
        );
    }
}
