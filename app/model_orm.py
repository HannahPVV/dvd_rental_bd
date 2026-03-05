from app.database import Base
from datetime import datetime, date
from typing import  Optional
from sqlalchemy import String, Integer, Numeric, Boolean, DateTime, Date, ForeignKey, text
from sqlalchemy.orm import  Mapped, mapped_column, relationship

# Clase base para todos los modelos (las tablas que pensamos son más útiles para nuestro proyecto)

class Address(Base):
    __tablename__ = "address"
    address_id: Mapped[int] = mapped_column(Integer, primary_key=True)
    address: Mapped[str] = mapped_column(String(100), nullable=False)
    last_update: Mapped[datetime] = mapped_column(DateTime, server_default=text("now()"), nullable=False)

class Store(Base):
    __tablename__ = "store"
    store_id: Mapped[int] = mapped_column(Integer, primary_key=True)
    manager_staff_id: Mapped[int] = mapped_column(Integer, ForeignKey("staff.staff_id"), nullable=False)
    address_id: Mapped[int] = mapped_column(Integer, ForeignKey("address.address_id"), nullable=False)
    last_update: Mapped[datetime] = mapped_column(DateTime, server_default=text("now()"), nullable=False)

class Staff(Base):
    __tablename__ = "staff"
    staff_id: Mapped[int] = mapped_column(Integer, primary_key=True)
    first_name: Mapped[str] = mapped_column(String(40), nullable=False)
    last_name: Mapped[str] = mapped_column(String(40), nullable=False)
    address_id: Mapped[int] = mapped_column(Integer, ForeignKey("address.address_id"), nullable=False)
    email: Mapped[Optional[str]] = mapped_column(String(50))
    store_id: Mapped[int] = mapped_column(Integer, ForeignKey("store.store_id"), nullable=False)
    active: Mapped[bool] = mapped_column(Boolean, server_default=text("true"), nullable=False)
    last_update: Mapped[datetime] = mapped_column(DateTime, server_default=text("now()"), nullable=False)

class Customer(Base):
    __tablename__ = "customer"
    customer_id: Mapped[int] = mapped_column(Integer, primary_key=True)
    store_id: Mapped[int] = mapped_column(Integer, ForeignKey("store.store_id"), nullable=False)
    first_name: Mapped[str] = mapped_column(String(40), nullable=False)
    last_name: Mapped[str] = mapped_column(String(40), nullable=False)
    email: Mapped[Optional[str]] = mapped_column(String(50))
    address_id: Mapped[int] = mapped_column(Integer, ForeignKey("address.address_id"), nullable=False)
    activebool: Mapped[bool] = mapped_column(Boolean, server_default=text("true"), nullable=False)
    create_date: Mapped[date] = mapped_column(Date, server_default=text("CURRENT_DATE"), nullable=False)
    last_update: Mapped[Optional[datetime]] = mapped_column(DateTime, server_default=text("now()"))
    active: Mapped[Optional[int]] = mapped_column(Integer)


class Category(Base):
    __tablename__ = "category"
    category_id: Mapped[int] = mapped_column(Integer, primary_key=True)
    name: Mapped[str] = mapped_column(String(30), nullable=False)
    last_update: Mapped[datetime] = mapped_column(DateTime, server_default=text("now()"), nullable=False)

class FilmCategory(Base):
    __tablename__ = "film_category"
    film_id: Mapped[int] = mapped_column(Integer, ForeignKey("film.film_id"), primary_key=True)
    category_id: Mapped[int] = mapped_column(Integer, ForeignKey("category.category_id"), primary_key=True)
    last_update: Mapped[datetime] = mapped_column(DateTime, server_default=text("now()"), nullable=False)

class Film(Base):
    __tablename__ = "film"
    film_id: Mapped[int] = mapped_column(Integer, primary_key=True)
    title: Mapped[str] = mapped_column(String(150), nullable=False)
    description: Mapped[Optional[str]] = mapped_column(String)
    release_year: Mapped[Optional[int]] = mapped_column(Integer)
    rental_duration: Mapped[int] = mapped_column(Integer, server_default=text("3"), nullable=False)
    rental_rate: Mapped[float] = mapped_column(Numeric(4, 2), server_default=text("4.99"), nullable=False)
    length: Mapped[Optional[int]] = mapped_column(Integer)
    replacement_cost: Mapped[float] = mapped_column(Numeric(5, 2), server_default=text("19.99"), nullable=False)
    last_update: Mapped[datetime] = mapped_column(DateTime, server_default=text("now()"), nullable=False)
    inventories = relationship("Inventory", back_populates="film") #Raquel: Relaciones para poder hacer el Q2


class Inventory(Base):
    __tablename__ = "inventory"
    inventory_id: Mapped[int] = mapped_column(Integer, primary_key=True)
    film_id: Mapped[int] = mapped_column(Integer, ForeignKey("film.film_id"), nullable=False)
    store_id: Mapped[int] = mapped_column(Integer, ForeignKey("store.store_id"), nullable=False)
    last_update: Mapped[datetime] = mapped_column(DateTime, server_default=text("now()"), nullable=False)
    film = relationship("Film", back_populates="inventories")
    rentals = relationship("Rental", back_populates="inventory") #Raquel: Relaciones para poder hacer el Q2



class Rental(Base):
    __tablename__ = "rental"
    rental_id: Mapped[int] = mapped_column(Integer, primary_key=True)
    rental_date: Mapped[datetime] = mapped_column(DateTime, nullable=False)
    inventory_id: Mapped[int] = mapped_column(Integer, ForeignKey("inventory.inventory_id"), nullable=False)
    customer_id: Mapped[int] = mapped_column(Integer, ForeignKey("customer.customer_id"), nullable=False)
    return_date: Mapped[Optional[datetime]] = mapped_column(DateTime)
    staff_id: Mapped[int] = mapped_column(Integer, ForeignKey("staff.staff_id"), nullable=False)
    last_update: Mapped[datetime] = mapped_column(DateTime, server_default=text("now()"), nullable=False)
    inventory = relationship("Inventory", back_populates="rentals")#Raquel: Relaciones para poder hacer el Q2



class Payment(Base):
    __tablename__ = "payment"
    payment_id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True, autoincrement=True)
    customer_id: Mapped[int] = mapped_column(Integer, ForeignKey("customer.customer_id"), nullable=False)
    staff_id: Mapped[int] = mapped_column(Integer, ForeignKey("staff.staff_id"), nullable=False)
    rental_id: Mapped[int] = mapped_column(Integer, ForeignKey("rental.rental_id"), nullable=False)
    amount: Mapped[float] = mapped_column(Numeric(5, 2), nullable=False)
    payment_date: Mapped[datetime] = mapped_column(DateTime, primary_key=True, nullable=False)

   