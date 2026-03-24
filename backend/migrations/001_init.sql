-- 数据库初始化脚本 v001
-- 日期: 2026-03-24

-- 菜系表
CREATE TABLE IF NOT EXISTS cuisines (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    name_en TEXT NOT NULL,
    icon_url TEXT,
    cover_image_url TEXT,
    tags TEXT,
    dish_count INTEGER DEFAULT 0,
    created_at INTEGER DEFAULT (unixepoch()),
    updated_at INTEGER DEFAULT (unixepoch())
);

-- 菜品表
CREATE TABLE IF NOT EXISTS dishes (
    id TEXT PRIMARY KEY,
    cuisine_id TEXT NOT NULL,
    name TEXT NOT NULL,
    image_url TEXT,
    thumbnail_url TEXT,
    calories_min INTEGER,
    calories_max INTEGER,
    calories_unit TEXT DEFAULT 'kcal',
    tags TEXT,
    difficulty TEXT,
    cook_time TEXT,
    ai_recommendation TEXT,
    recipe TEXT,
    created_at INTEGER DEFAULT (unixepoch()),
    FOREIGN KEY (cuisine_id) REFERENCES cuisines(id)
);

-- 推荐历史表
CREATE TABLE IF NOT EXISTS recommendation_history (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id TEXT NOT NULL,
    dish_id TEXT NOT NULL,
    cuisine_id TEXT NOT NULL,
    recommended_at INTEGER DEFAULT (unixepoch()),
    liked INTEGER DEFAULT 0,
    FOREIGN KEY (dish_id) REFERENCES dishes(id),
    FOREIGN KEY (cuisine_id) REFERENCES cuisines(id)
);

-- 用户偏好表
CREATE TABLE IF NOT EXISTS user_preferences (
    user_id TEXT PRIMARY KEY,
    disliked_cuisines TEXT,
    disliked_tags TEXT,
    preferred_dish_ids TEXT,
    settings TEXT,
    created_at INTEGER DEFAULT (unixepoch()),
    updated_at INTEGER DEFAULT (unixepoch())
);

-- 索引
CREATE INDEX IF NOT EXISTS idx_dishes_cuisine ON dishes(cuisine_id);
CREATE INDEX IF NOT EXISTS idx_history_user ON recommendation_history(user_id);
CREATE INDEX IF NOT EXISTS idx_history_user_recent ON recommendation_history(user_id, recommended_at DESC);

-- 种子数据: 菜系
INSERT INTO cuisines (id, name, name_en, icon_url, cover_image_url, tags, dish_count) VALUES
('chinese_sichuan', '川菜', 'Sichuan', 'https://images.unsplash.com/photo-1584269600464-37b1b58a9fe3?w=200', 'https://images.unsplash.com/photo-1584269600464-37b1b58a9fe3?w=800', '["辣","麻辣","经典"]', 28),
('chinese_cantonese', '粤菜', 'Cantonese', 'https://images.unsplash.com/photo-1563245372-f21724e3856d?w=200', 'https://images.unsplash.com/photo-1563245372-f21724e3856d?w=800', '["清淡","鲜嫩","养生"]', 24),
('chinese_hunan', '湘菜', 'Hunan', 'https://images.unsplash.com/photo-1569058242567-93de6f36f8eb?w=200', 'https://images.unsplash.com/photo-1569058242567-93de6f36f8eb?w=800', '["辣","酸辣","开胃"]', 20),
('chinese_shandong', '鲁菜', 'Shandong', 'https://images.unsplash.com/photo-1571867424488-4565932edb41?w=200', 'https://images.unsplash.com/photo-1571867424488-4565932edb41?w=800', '["鲜香","咸鲜","清淡"]', 18),
('chinese_jiangsu', '苏菜', 'Jiangsu', 'https://images.unsplash.com/photo-1555126634-323283e090fa?w=200', 'https://images.unsplash.com/photo-1555126634-323283e090fa?w=800', '["清淡","甜","精致"]', 22);

-- 种子数据: 菜品（每种菜系2道）
INSERT INTO dishes (id, cuisine_id, name, image_url, thumbnail_url, calories_min, calories_max, tags, difficulty, cook_time, ai_recommendation, recipe) VALUES
('dish_kungpao_chicken', 'chinese_sichuan', '宫保鸡丁', 'https://images.unsplash.com/photo-1525755662778-989d0524087e?w=800', 'https://images.unsplash.com/photo-1525755662778-989d0524087e?w=200', 250, 350, '["经典","下饭","微辣"]', '简单', '25分钟', '经典川菜代表，花生与鸡丁的完美碰撞，麻辣鲜香，下饭神器！', '{"ingredients":[{"name":"鸡胸肉","amount":"300g"},{"name":"花生米","amount":"50g"},{"name":"干辣椒","amount":"8-10个"},{"name":"花椒","amount":"一小把"},{"name":"葱段","amount":"适量"}],"steps":["鸡胸肉切丁，加料酒、淀粉腌制15分钟","花生米小火炒至金黄酥脆","调制酱汁：酱油、醋、糖、淀粉水混合","锅中热油，爆香花椒和干辣椒","放入鸡丁滑炒至变色，倒入酱汁翻炒均匀"],"tips":["花生米最后放，保持酥脆口感"]}'),
('dish_mapo_tofu', 'chinese_sichuan', '麻婆豆腐', 'https://images.unsplash.com/photo-1582576163090-09d3b1259f30?w=800', 'https://images.unsplash.com/photo-1582576163090-09d3b1259f30?w=200', 180, 280, '["经典","麻辣","下饭"]', '简单', '20分钟', '川菜经典，豆腐嫩滑，麻辣鲜香，一口就上头！', '{"ingredients":[{"name":"豆腐","amount":"400g"},{"name":"肉末","amount":"100g"},{"name":"豆瓣酱","amount":"2勺"},{"name":"花椒","amount":"适量"},{"name":"蒜末","amount":"适量"}],"steps":["豆腐切块焯水备用","锅中热油，炒香肉末","加入豆瓣酱炒出红油","加入豆腐轻轻翻炒","加水焖煮2分钟，勾芡出锅"],"tips":["豆腐焯水可去豆腥味"]}'),
('dish_white_boiled_fish', 'chinese_cantonese', '清蒸鱼', 'https://images.unsplash.com/photo-1580048915913-4f8f5cb481c4?w=800', 'https://images.unsplash.com/photo-1580048915913-4f8f5cb481c4?w=200', 150, 220, '["清淡","养生","鲜嫩"]', '中等', '30分钟', '粤菜精髓，原汁原味，鱼肉嫩滑如豆腐，鲜到眉毛掉！', '{"ingredients":[{"name":"鲈鱼","amount":"1条（约500g）"},{"name":"姜丝","amount":"10g"},{"name":"葱丝","amount":"10g"},{"name":"蒸鱼豉油","amount":"2勺"},{"name":"热油","amount":"适量"}],"steps":["鱼处理干净，两面划刀","鱼身铺上姜丝","水开后上锅蒸8-10分钟","取出倒掉蒸出的水","铺上葱丝，淋上蒸鱼豉油，热油浇上"],"tips":["蒸鱼时间根据鱼的大小调整"]}'),
('dish_char_siu', 'chinese_cantonese', '叉烧肉', 'https://images.unsplash.com/photo-1544025162-d76694265947?w=800', 'https://images.unsplash.com/photo-1544025162-d76694265947?w=200', 280, 380, '["经典","甜香","色泽红润"]', '中等', '40分钟', '港式经典，外焦里嫩，甜咸交织，吃一口就爱上！', '{"ingredients":[{"name":"梅花肉","amount":"500g"},{"name":"叉烧酱","amount":"3勺"},{"name":"蜂蜜","amount":"1勺"},{"name":"生抽","amount":"1勺"},{"name":"红曲粉","amount":"少许"}],"steps":["梅花肉切成长条","用叉烧酱、蜂蜜、生抽腌制过夜","烤箱预热200度，烤25分钟","中途翻面并刷蜂蜜","切片即可享用"],"tips":["腌制时间越长越入味"]}'),
('dish_Chairman_mao_pork', 'chinese_hunan', '毛氏红烧肉', 'https://images.unsplash.com/photo-1623689046286-adcf6bc93a5b?w=800', 'https://images.unsplash.com/photo-1623689046286-adcf6bc93a5b?w=200', 350, 450, '["经典","色泽红亮","软糯"]', '中等', '60分钟', '湘菜之王，色泽红亮如宝石，入口即化，肥而不腻！', '{"ingredients":[{"name":"五花肉","amount":"500g"},{"name":"冰糖","amount":"30g"},{"name":"八角","amount":"2个"},{"name":"桂皮","amount":"1小块"},{"name":"生抽","amount":"2勺"}],"steps":["五花肉切块，冷水下锅焯水","炒糖色：冰糖小火炒至焦糖色","下肉块翻炒上色","加入生抽、八角、桂皮，加水没过肉","大火烧开，转小火焖煮45分钟"],"tips":["炒糖色时火候要小"]}'),
('dish_spicy_crayfish', 'chinese_hunan', '口味虾', 'https://images.unsplash.com/photo-1587559335512-43745bfb5c87?w=800', 'https://images.unsplash.com/photo-1587559335512-43745bfb5c87?w=200', 200, 300, '["辣","夜宵","过瘾"]', '中等', '35分钟', '湘味十足，辣到飞起又停不下来，夏天必吃！', '{"ingredients":[{"name":"小龙虾","amount":"1kg"},{"name":"紫苏","amount":"适量"},{"name":"干辣椒","amount":"适量"},{"name":"蒜","amount":"1头"},{"name":"啤酒","amount":"1罐"}],"steps":["小龙虾刷洗干净，去虾线","锅中热油，爆香蒜末干辣椒","下小龙虾大火翻炒至变红","加入啤酒和调料，盖盖焖煮","出锅前加入紫苏翻炒均匀"],"tips":["小龙虾一定要炒熟透"]}'),
('dish_degu_braised_prawns', 'chinese_shandong', '德州扒鸡', 'https://images.unsplash.com/photo-1598103442097-8b74394b95c6?w=800', 'https://images.unsplash.com/photo-1598103442097-8b74394b95c6?w=200', 280, 380, '["经典","香嫩","脱骨"]', '较难', '90分钟', '鲁菜名吃，肉质软烂入味，轻轻一抖就脱骨！', '{"ingredients":[{"name":"三黄鸡","amount":"1只（约1kg）"},{"name":"八角","amount":"3个"},{"name":"桂皮","amount":"1块"},{"name":"花椒","amount":"适量"},{"name":"酱油","amount":"3勺"}],"steps":["鸡处理干净，用酱油涂抹上色","油温170度炸至金黄捞出","锅中加入高汤，放香料","放入炸好的鸡，大火烧开转小火焖2小时","捞出沥干汤汁即可"],"tips":["炸鸡时油温要够"]}'),
('dish_葱烧海参', 'chinese_shandong', '葱烧海参', 'https://images.unsplash.com/photo-1559847844-5315695dadae?w=800', 'https://images.unsplash.com/photo-1559847844-5315695dadae?w=200', 150, 250, '["高端","滋补","鲜美"]', '较难', '45分钟', '鲁菜经典，海参软糯Q弹，葱香四溢，海鲜控的最爱！', '{"ingredients":[{"name":"海参","amount":"4条"},{"name":"大葱","amount":"2根"},{"name":"高汤","amount":"200ml"},{"name":"酱油","amount":"1勺"},{"name":"淀粉","amount":"适量"}],"steps":["海参泡发，切成条状","大葱切段，炸至金黄备用","锅中加入高汤，放入海参","加入酱油调味，小火煨10分钟","勾芡，出锅铺上葱段"],"tips":["海参泡发需要12小时以上"]}'),
('dish_squirrel_fish', 'chinese_jiangsu', '松鼠桂鱼', 'https://images.unsplash.com/photo-1611143669185-af224c5e3252?w=800', 'https://images.unsplash.com/photo-1611143669185-af224c5e3252?w=200', 220, 320, '["经典","酸甜","造型独特"]', '较难', '50分钟', '苏菜代表作，外酥里嫩，酸甜适口，造型精美如松鼠！', '{"ingredients":[{"name":"桂鱼","amount":"1条（约600g）"},{"name":"番茄酱","amount":"3勺"},{"name":"糖","amount":"2勺"},{"name":"醋","amount":"1勺"},{"name":"淀粉","amount":"适量"}],"steps":["桂鱼处理干净，在鱼身上打花刀","裹上干淀粉，油炸至金黄酥脆","另起锅，调酸甜汁（番茄酱、糖、醋）","将酸甜汁淋在炸好的鱼身上","撒上松子仁即可"],"tips":["打花刀时要切到骨头"]}'),
('dish_yangzhou_fried_rice', 'chinese_jiangsu', '扬州炒饭', 'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=800', 'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=200', 300, 400, '["经典","主食","丰盛"]', '简单', '20分钟', '米饭粒粒分明，配料丰富，一碗炒饭也是盛宴！', '{"ingredients":[{"name":"米饭","amount":"2碗"},{"name":"鸡蛋","amount":"2个"},{"name":"虾仁","amount":"50g"},{"name":"火腿","amount":"30g"},{"name":"青豆","amount":"30g"}],"steps":["米饭打散，鸡蛋打散备用","锅中热油，炒散鸡蛋盛出","下虾仁、火腿丁、青豆翻炒","下米饭大火翻炒均匀","加入鸡蛋碎，调味翻炒出锅"],"tips":["米饭要用隔夜饭，水分少更易炒散"]}');
