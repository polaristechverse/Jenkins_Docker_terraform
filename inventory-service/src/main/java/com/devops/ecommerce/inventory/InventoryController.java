package com.devops.ecommerce.inventory;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/inventory")
public class InventoryController {

    @GetMapping
    public String checkInventory() {
        return "Stock Available: YES";
    }
}
