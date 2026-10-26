CREATE TABLE IF NOT EXISTS favorites (
  user_id INT NOT NULL,
  product_id INT NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id, product_id),
  CONSTRAINT fk_favorites_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_favorites_product FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);
