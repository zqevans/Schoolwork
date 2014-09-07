//
//  main.cpp
//  Lab 7
//
//  Created by Zach Evans on 11/29/12.
//  Copyright (c) 2012 Zach Evans. All rights reserved.
//

#include <iostream>

using namespace std;

class Customer
{
public:
    Customer(string customer_name, string customer_address, string customer_city, string customer_state, string customer_zipcode);
    
    string get_name()  const;
    string get_address() const;
    string get_city()  const;
    string get_state() const;
    string get_zipcode() const;
    int getNumPurchases() const;
    double getTotalSales() const;
    double getCreditLimit() const;
    double getUnpaidBalance() const;
    
    void addPurchase(double purchasePrice);
    void setCreditLimit(double num);
    void increase_limit(double amount);
    
private:
    string name;
    string address;
    string city;
    string state;
    string zipcode;
    int numPurchases;
    double totalSales;
    double creditLimit;
    double unpaidBalance;
};

Customer::Customer(string customer_name, string customer_address, string customer_city, string customer_state, string customer_zipcode){
    name = customer_name;
    address = customer_address;
    city = customer_city;
    state = customer_state;
    zipcode = customer_zipcode;
    numPurchases = 0;
    totalSales = 0.0;
    creditLimit = 0.0;
    
}

string Customer::get_name()  const { return name; }
string Customer::get_address() const { return address; }
string Customer::get_city()  const { return city; }
string Customer::get_state() const { return state; }
string Customer::get_zipcode() const { return zipcode; }
int Customer::getNumPurchases() const { return numPurchases; }
double Customer::getTotalSales() const { return totalSales; }
double Customer::getCreditLimit() const { return creditLimit; }
double Customer::getUnpaidBalance() const { return unpaidBalance; }


void Customer::addPurchase(double purchasePrice){
    
    
    if ((unpaidBalance + purchasePrice) <= creditLimit){
        numPurchases++;
        totalSales += purchasePrice;
        unpaidBalance += purchasePrice;
    }
    else{
        cout << "Credit limit exceeded. This purchase cannot be made.\n";
    }
}

void Customer::setCreditLimit(double num){
    creditLimit = num;
    
}
void Customer::increase_limit(double amount){
    creditLimit += amount;
}

void printCustomerBalance(Customer &inCustomer){
    cout << inCustomer.get_name() << " has an unpaid balance of $" << inCustomer.getUnpaidBalance()
         << " and a credit limit of $" << inCustomer.getCreditLimit() << ",\n";
}


int main(int argc, const char * argv[])
{
    
    Customer newCustomer = Customer("Bob", "1234 Main St.", "Anytown", "WA", "12345");
    
    newCustomer.setCreditLimit(1000);
    
    newCustomer.addPurchase(500.0);
    printCustomerBalance(newCustomer);
    
    newCustomer.addPurchase(450.0);
    printCustomerBalance(newCustomer);
    
    newCustomer.addPurchase(100.0); //Should not go through
    printCustomerBalance(newCustomer);
    
    return 0;
}

