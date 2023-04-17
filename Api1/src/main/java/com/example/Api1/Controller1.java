package com.example.Api1;

import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/")
@CrossOrigin
public class Controller1 {

    @GetMapping("/")
    public String f1(){
        System.out.println("In API 1");
        return "Welcome to API 1";
    }

    @GetMapping("/api")
    public String f2(){
        System.out.println("In API 1.1");
        return "Welcome to API 1.1";
    }
}
