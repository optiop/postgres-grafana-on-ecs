-- Create a user table
CREATE TABLE usage(
  id SERIAL PRIMARY KEY,
  month VARCHAR(100) NOT NULL,
  usage INTEGER NOT NULL
);

INSERT INTO usage (month, usage) VALUES ('January', 1000);
INSERT INTO usage (month, usage) VALUES ('February', 2000);
INSERT INTO usage (month, usage) VALUES ('March', 2500);
INSERT INTO usage (month, usage) VALUES ('April', 3500);
INSERT INTO usage (month, usage) VALUES ('May', 1500);
INSERT INTO usage (month, usage) VALUES ('June', 1300);
INSERT INTO usage (month, usage) VALUES ('July', 1600);
INSERT INTO usage (month, usage) VALUES ('August', 3600);
INSERT INTO usage (month, usage) VALUES ('September', 1600);
INSERT INTO usage (month, usage) VALUES ('October', 1600);
INSERT INTO usage (month, usage) VALUES ('November', 1600);