package com.devops.ecommerce.payment;

import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/payment")
public class PaymentController {

    @PostMapping
    public String makePayment() {
        return "Payment Successful!";
    }
}
