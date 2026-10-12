// ====================================================================
// MALL MANAGEMENT SYSTEM - FRONTEND CLIENT JAVASCRIPT
// Handles reactive UI, API integrations, Charts, POS Cart, Modals
// ====================================================================

let globalShops = [];
let globalCustomers = [];
let globalProducts = [];
let posCart = []; // [{product, quantity}]
let chartsInstances = {};

// --------------------------------------------------------------------
// INITIALIZATION
// --------------------------------------------------------------------
document.addEventListener("DOMContentLoaded", () => {
  initApp();
});

async function initApp() {
  await Promise.all([
    loadDashboardStats(),
    loadShopsData(),
    loadCustomersData(),
    loadProductsData()
  ]);
  // Populate dropdowns used across modals
  populateDropdowns();
}

// --------------------------------------------------------------------
// TAB NAVIGATION
// --------------------------------------------------------------------
function switchTab(tabId) {
  // Update nav buttons
  document.querySelectorAll(".nav-btn").forEach(btn => {
    btn.classList.remove("active", "bg-brand-600/10", "text-brand-400", "font-bold");
    btn.classList.add("text-slate-300");
  });
  const activeNav = document.getElementById(`nav-${tabId}`);
  if (activeNav) {
    activeNav.classList.add("active", "bg-brand-600/10", "text-brand-400", "font-bold");
    activeNav.classList.remove("text-slate-300");
  }

  // Update tab panes
  document.querySelectorAll(".tab-pane").forEach(pane => {
    pane.classList.add("hidden");
  });
  const targetPane = document.getElementById(`tab-${tabId}`);
  if (targetPane) {
    targetPane.classList.remove("hidden");
  }

  // Header Title Updates
  const titleMap = {
    "dashboard": "Mall Operations Dashboard",
    "pos": "Point of Sale (POS) Billing & Transactions",
    "shops": "Mall Shops, Tenants & Lease Contracts",
    "products": "Inventory Catalog & Promotional Offers",
    "customers": "Customer Registry & Membership Loyalty",
    "parking": "Smart Multi-Level Parking Facility (B1 - B3)",
    "events": "Mall Events & Customer RSVPs",
    "support": "Customer Complaints & Maintenance Operations",
    "analytics": "10 DBMS Analytical Reports (Case Study Spec)",
    "sql-studio": "Interactive DBMS SQL Console & ER Schema"
  };
  const subtitleMap = {
    "dashboard": "Live KPIs & Relational Aggregations",
    "pos": "Simulates Real-time Purchases with Stock & Points Triggers",
    "shops": "Commercial Space Allocation & Revenue",
    "products": "Real-time Stock Control with Low Stock Alerts",
    "customers": "Automated Silver, Gold & Platinum Loyalty Tier Management",
    "parking": "2D Slot Visualizer with Hourly Tariff Automation",
    "events": "Event Schedule & Capacity Tracking",
    "support": "Issue Logging, Work Orders & Staff Assignments",
    "analytics": "Aggregations, Group By, Views & Complex Analytical Queries",
    "sql-studio": "Direct SQL Execution, EXPLAIN Plan & ER Diagram"
  };

  document.getElementById("page-title").textContent = titleMap[tabId] || "Nexus Mall System";
  document.getElementById("page-subtitle").textContent = subtitleMap[tabId] || "DBMS Mini Project";

  // Specific tab data loads
  if (tabId === "dashboard") loadDashboardStats();
  if (tabId === "pos") initPosTab();
  if (tabId === "shops") loadShopsData();
  if (tabId === "products") loadProductsData();
  if (tabId === "customers") loadCustomersData();
  if (tabId === "parking") loadParkingData();
  if (tabId === "events") loadEventsData();
  if (tabId === "support") loadSupportData();
  if (tabId === "analytics") loadAnalyticsData();
  if (tabId === "sql-studio") loadSchemaBrowser();
}

function switchSqlSubTab(subTab) {
  const tabs = ['console', 'er-diagram', 'schema-browser', 'downloads'];
  tabs.forEach(t => {
    const btn = document.getElementById(`subtab-btn-${t}`);
    const view = document.getElementById(`subtab-view-${t}`);
    if (btn && view) {
      if (t === subTab) {
        btn.className = "pb-3 text-sm font-bold border-b-2 border-brand-600 text-brand-600";
        view.classList.remove("hidden");
      } else {
        btn.className = "pb-3 text-sm font-semibold text-slate-500 hover:text-slate-700";
        view.classList.add("hidden");
      }
    }
  });
}

// --------------------------------------------------------------------
// 1. DASHBOARD OVERVIEW
// --------------------------------------------------------------------
async function loadDashboardStats() {
  try {
    const res = await fetch("/api/dashboard/stats");
    const data = await res.json();
    if (!data.success) return;

    const stats = data.stats;
    document.getElementById("stat-revenue").textContent = formatCurrency(stats.total_sales);
    document.getElementById("stat-orders-count").textContent = `${stats.total_orders} purchases recorded`;
    
    document.getElementById("stat-shops").textContent = `${stats.active_leases} / ${stats.total_shops}`;
    document.getElementById("stat-rent").textContent = formatCurrency(stats.monthly_rent_roll);
    
    document.getElementById("stat-parking").textContent = `${stats.parking_rate}%`;
    document.getElementById("stat-parking-slots").textContent = `${stats.parking_occupied} of ${stats.parking_total}`;
    
    document.getElementById("stat-issues").textContent = `${stats.open_complaints + stats.pending_maintenance} Open`;
    document.getElementById("stat-urgent").textContent = `${stats.urgent_complaints} urgent`;

    // Render Recent Purchases Table
    const tbody = document.getElementById("dashboard-recent-purchases");
    if (data.recent_purchases && data.recent_purchases.length > 0) {
      tbody.innerHTML = data.recent_purchases.map(p => `
        <tr class="hover:bg-slate-50/80 transition">
          <td class="py-2.5 px-3 font-mono text-xs font-semibold text-slate-500">#${p.purchase_id}</td>
          <td class="py-2.5 px-3 font-semibold text-slate-800">${escapeHtml(p.customer_name)}</td>
          <td class="py-2.5 px-3 text-slate-600">${escapeHtml(p.shop_name)}</td>
          <td class="py-2.5 px-3">
            <span class="text-[11px] px-2 py-0.5 rounded-full font-medium ${getPaymentBadgeClass(p.payment_method)}">
              ${escapeHtml(p.payment_method || 'Cash')}
            </span>
          </td>
          <td class="py-2.5 px-3 text-right font-mono font-bold text-slate-900">${formatCurrency(p.total_amount)}</td>
          <td class="py-2.5 px-3 text-right">
            <button onclick="viewReceipt(${p.purchase_id})" class="text-xs text-brand-600 hover:text-brand-700 font-semibold">
              <i class="fa-solid fa-receipt"></i>
            </button>
          </td>
        </tr>
      `).join("");
    } else {
      tbody.innerHTML = `<tr><td colspan="6" class="text-center py-4 text-xs text-slate-400">No purchases yet.</td></tr>`;
    }

  } catch (err) {
    console.error("Error loading dashboard stats:", err);
  }
}

// --------------------------------------------------------------------
// 2. POINT OF SALE (POS) BILLING
// --------------------------------------------------------------------
async function initPosTab() {
  populateDropdowns();
  onPosShopChange();
}

async function onPosShopChange() {
  const shopId = document.getElementById("pos-shop-select").value;
  if (!shopId) return;

  // Clear cart on shop switch to maintain shop consistency
  posCart = [];
  renderPosCart();

  // Load shop products
  const res = await fetch(`/api/products?shop_id=${shopId}`);
  const data = await res.json();
  const grid = document.getElementById("pos-products-grid");
  const countSpan = document.getElementById("pos-product-count");

  if (!data.success || data.products.length === 0) {
    grid.innerHTML = `<p class="col-span-2 text-xs text-slate-400 py-6 text-center italic">No products registered for this shop outlet.</p>`;
    countSpan.textContent = "0 items";
    return;
  }

  countSpan.textContent = `${data.products.length} items`;
  grid.innerHTML = data.products.map(p => `
    <div onclick="addToPosCart(${p.product_id})" class="p-3 bg-slate-50 hover:bg-brand-50/50 border border-slate-200 hover:border-brand-300 rounded-xl cursor-pointer transition flex flex-col justify-between group">
      <div>
        <div class="flex justify-between items-start">
          <span class="text-[10px] font-semibold text-slate-600 bg-white px-1.5 py-0.5 rounded border border-slate-200">${escapeHtml(p.category)}</span>
          <span class="text-[11px] font-mono ${p.stock_quantity <= 5 ? 'text-rose-600 font-bold' : 'text-slate-600'}">
            Stock: ${p.stock_quantity}
          </span>
        </div>
        <h4 class="font-bold text-slate-800 text-sm mt-1.5 group-hover:text-brand-600 transition leading-snug">${escapeHtml(p.product_name)}</h4>
      </div>
      <div class="flex justify-between items-center mt-3 pt-2 border-t border-slate-200/60">
        <span class="font-mono font-bold text-slate-900 text-sm">${formatCurrency(p.price)}</span>
        <button class="w-7 h-7 rounded-lg bg-brand-600 text-white flex items-center justify-center text-xs group-hover:scale-105 transition shadow-sm">
          <i class="fa-solid fa-plus"></i>
        </button>
      </div>
    </div>
  `).join("");

  // Load shop offers
  loadPosOffers(shopId);
}

async function loadPosOffers(shopId) {
  const offerSelect = document.getElementById("pos-offer-select");
  const offerTag = document.getElementById("pos-active-offer-tag");
  const offerName = document.getElementById("pos-active-offer-name");
  
  const res = await fetch(`/api/offers?shop_id=${shopId}`);
  const data = await res.json();

  offerSelect.innerHTML = `<option value="">No Promotional Offer Applied</option>`;
  if (data.success && data.offers.length > 0) {
    offerTag.classList.remove("hidden");
    offerName.textContent = `${data.offers[0].offer_name} (${data.offers[0].discount_percentage}% OFF)`;
    data.offers.forEach(o => {
      const opt = document.createElement("option");
      opt.value = o.offer_id;
      opt.dataset.pct = o.discount_percentage;
      opt.textContent = `${o.offer_name} - ${o.discount_percentage}% Discount`;
      offerSelect.appendChild(opt);
    });
  } else {
    offerTag.classList.add("hidden");
  }
}

async function addToPosCart(productId) {
  const shopId = document.getElementById("pos-shop-select").value;
  const res = await fetch(`/api/products?shop_id=${shopId}`);
  const data = await res.json();
  const prod = data.products.find(p => p.product_id === productId);
  if (!prod) return;

  const existing = posCart.find(item => item.product_id === productId);
  if (existing) {
    if (existing.quantity >= prod.stock_quantity) {
      showToast(`Cannot add more than available stock (${prod.stock_quantity})!`, "warning");
      return;
    }
    existing.quantity += 1;
  } else {
    if (prod.stock_quantity <= 0) {
      showToast("This item is currently out of stock!", "error");
      return;
    }
    posCart.push({
      product_id: prod.product_id,
      product_name: prod.product_name,
      price: prod.price,
      max_stock: prod.stock_quantity,
      quantity: 1
    });
  }
  renderPosCart();
}

function changePosCartQty(productId, delta) {
  const item = posCart.find(i => i.product_id === productId);
  if (!item) return;

  item.quantity += delta;
  if (item.quantity <= 0) {
    posCart = posCart.filter(i => i.product_id !== productId);
  } else if (item.quantity > item.max_stock) {
    item.quantity = item.max_stock;
    showToast(`Maximum available stock reached (${item.max_stock})`, "warning");
  }
  renderPosCart();
}

function clearPosCart() {
  posCart = [];
  renderPosCart();
}

function renderPosCart() {
  const container = document.getElementById("pos-cart-items");
  const subtotalElem = document.getElementById("pos-subtotal");
  const discountElem = document.getElementById("pos-discount");
  const totalElem = document.getElementById("pos-total");

  if (posCart.length === 0) {
    container.innerHTML = `<p class="text-xs text-slate-400 py-6 text-center italic">No items selected yet. Click products on the left to add.</p>`;
    subtotalElem.textContent = "$0.00";
    discountElem.textContent = "-$0.00";
    totalElem.textContent = "$0.00";
    return;
  }

  let subtotal = 0;
  container.innerHTML = posCart.map(item => {
    const itemTotal = item.price * item.quantity;
    subtotal += itemTotal;
    return `
      <div class="flex justify-between items-center bg-slate-50 p-2.5 rounded-lg border border-slate-200">
        <div class="flex-1 pr-2">
          <p class="text-xs font-bold text-slate-800 leading-tight">${escapeHtml(item.product_name)}</p>
          <p class="text-[11px] text-slate-500 font-mono">${formatCurrency(item.price)} each</p>
        </div>
        <div class="flex items-center space-x-2">
          <div class="flex items-center border border-slate-300 rounded bg-white">
            <button onclick="changePosCartQty(${item.product_id}, -1)" class="w-6 h-6 flex items-center justify-center text-xs text-slate-600 hover:bg-slate-100">&minus;</button>
            <span class="w-7 text-center font-mono text-xs font-bold">${item.quantity}</span>
            <button onclick="changePosCartQty(${item.product_id}, 1)" class="w-6 h-6 flex items-center justify-center text-xs text-slate-600 hover:bg-slate-100">&plus;</button>
          </div>
          <span class="w-16 text-right font-mono font-bold text-xs text-slate-900">${formatCurrency(itemTotal)}</span>
        </div>
      </div>
    `;
  }).join("");

  // Calculate discount if offer selected
  const offerSelect = document.getElementById("pos-offer-select");
  let discount = 0;
  if (offerSelect.selectedIndex > 0) {
    const selectedOpt = offerSelect.options[offerSelect.selectedIndex];
    const pct = parseFloat(selectedOpt.dataset.pct || 0);
    discount = (subtotal * pct) / 100.0;
  }

  const finalTotal = Math.max(0, subtotal - discount);

  subtotalElem.textContent = formatCurrency(subtotal);
  discountElem.textContent = `-${formatCurrency(discount)}`;
  totalElem.textContent = formatCurrency(finalTotal);
}

async function submitPosCheckout() {
  const customerId = document.getElementById("pos-customer-select").value;
  const shopId = document.getElementById("pos-shop-select").value;
  const offerId = document.getElementById("pos-offer-select").value || null;
  const paymentMethod = document.querySelector('input[name="pos-payment-method"]:checked').value;

  if (!customerId) {
    showToast("Please select or register a customer for this sale!", "error");
    return;
  }
  if (!shopId) {
    showToast("Please select a valid shop outlet!", "error");
    return;
  }
  if (posCart.length === 0) {
    showToast("Cart is empty! Add at least one item.", "error");
    return;
  }

  const payload = {
    customer_id: parseInt(customerId),
    shop_id: parseInt(shopId),
    items: posCart.map(i => ({ product_id: i.product_id, quantity: i.quantity })),
    offer_id: offerId ? parseInt(offerId) : null,
    payment_method: paymentMethod
  };

  const btn = document.getElementById("pos-checkout-btn");
  btn.disabled = true;
  btn.innerHTML = `<i class="fa-solid fa-spinner fa-spin"></i> Processing Transaction...`;

  try {
    const res = await fetch("/api/purchases", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload)
    });
    const result = await res.json();

    if (result.success) {
      showToast("Purchase recorded successfully! Loyalty points awarded.", "success");
      clearPosCart();
      // Refresh inventory and stats
      onPosShopChange();
      loadDashboardStats();
      // View Receipt
      viewReceipt(result.purchase_id);
    } else {
      showToast(`Transaction failed: ${result.error}`, "error");
    }
  } catch (err) {
    showToast(`Error processing checkout: ${err}`, "error");
  } finally {
    btn.disabled = false;
    btn.innerHTML = `<i class="fa-solid fa-receipt"></i> <span>Complete Transaction & Print Receipt</span>`;
  }
}

async function viewReceipt(purchaseId) {
  try {
    const res = await fetch(`/api/purchases/${purchaseId}`);
    const data = await res.json();
    if (!data.success) return;

    const p = data.purchase;
    document.getElementById("rcpt-id").textContent = p.purchase_id;
    document.getElementById("rcpt-date").textContent = p.purchase_date;
    document.getElementById("rcpt-shop-name").textContent = p.shop_name;
    document.getElementById("rcpt-shop-floor").textContent = `${p.floor} | Ph: ${p.shop_phone || 'N/A'}`;
    document.getElementById("rcpt-cust-name").textContent = `${p.customer_name} (${p.phone})`;
    document.getElementById("rcpt-payment-method").textContent = p.payment_method;

    const itemsBody = document.getElementById("rcpt-items-body");
    let calculatedSubtotal = 0;
    let totalDiscount = 0;

    itemsBody.innerHTML = data.items.map(item => {
      const lineSubtotal = item.quantity * item.unit_price;
      calculatedSubtotal += lineSubtotal;
      totalDiscount += item.discount;
      return `
        <tr>
          <td class="py-1">${escapeHtml(item.product_name)}</td>
          <td class="py-1 text-center font-mono">${item.quantity}</td>
          <td class="py-1 text-right font-mono">${formatCurrency(item.unit_price)}</td>
          <td class="py-1 text-right font-mono font-bold">${formatCurrency(lineSubtotal - item.discount)}</td>
        </tr>
      `;
    }).join("");

    const discRow = document.getElementById("rcpt-discount-row");
    if (totalDiscount > 0) {
      discRow.classList.remove("hidden");
      document.getElementById("rcpt-discount").textContent = `-${formatCurrency(totalDiscount)}`;
    } else {
      discRow.classList.add("hidden");
    }

    document.getElementById("rcpt-total").textContent = formatCurrency(p.total_amount);
    openModal("receipt-modal");
  } catch (err) {
    console.error("Error viewing receipt:", err);
  }
}

// --------------------------------------------------------------------
// 3. SHOPS & LEASES
// --------------------------------------------------------------------
async function loadShopsData() {
  try {
    const res = await fetch("/api/shops");
    const data = await res.json();
    if (!data.success) return;

    globalShops = data.shops;
    renderShopsGrid(globalShops);
  } catch (err) {
    console.error("Error loading shops:", err);
  }
}

function renderShopsGrid(shops) {
  const grid = document.getElementById("shops-grid");
  if (!shops || shops.length === 0) {
    grid.innerHTML = `<p class="col-span-3 text-center py-8 text-xs text-slate-400">No shops found matching filter.</p>`;
    return;
  }

  grid.innerHTML = shops.map(s => `
    <div class="bg-white rounded-2xl border border-slate-200/80 p-5 shadow-sm hover:shadow-md transition space-y-3">
      <div class="flex justify-between items-start">
        <span class="text-[11px] font-semibold text-brand-600 bg-brand-50 px-2.5 py-0.5 rounded-full border border-brand-100">
          ${escapeHtml(s.category)}
        </span>
        <span class="text-xs px-2 py-0.5 rounded-full font-semibold ${getLeaseStatusClass(s.lease_status)}">
          ${escapeHtml(s.lease_status || 'No Lease')}
        </span>
      </div>

      <div>
        <h4 class="font-bold text-slate-800 text-base leading-tight">${escapeHtml(s.shop_name)}</h4>
        <p class="text-xs text-slate-500 mt-1 flex items-center space-x-1">
          <i class="fa-solid fa-location-dot text-slate-400"></i>
          <span>${escapeHtml(s.floor)} | Contact: ${escapeHtml(s.contact_no || 'N/A')}</span>
        </p>
      </div>

      <div class="border-t border-slate-100 pt-3 text-xs space-y-1.5">
        <div class="flex justify-between text-slate-600">
          <span>Tenant Entity:</span>
          <span class="font-semibold text-slate-800">${escapeHtml(s.tenant_name || 'Unassigned')}</span>
        </div>
        <div class="flex justify-between text-slate-600">
          <span>Monthly Rent:</span>
          <span class="font-mono font-bold text-slate-900">${formatCurrency(s.monthly_rent || 0)}</span>
        </div>
        <div class="flex justify-between text-slate-600">
          <span>Catalog Products:</span>
          <span class="font-semibold text-brand-600">${s.product_count} items</span>
        </div>
      </div>
    </div>
  `).join("");
}

function filterShopsByFloor(floor) {
  document.querySelectorAll(".floor-filter-btn").forEach(btn => {
    btn.className = "floor-filter-btn px-3 py-1.5 rounded-lg text-xs font-semibold bg-white border border-slate-200 text-slate-600";
  });
  event.target.className = "floor-filter-btn px-3 py-1.5 rounded-lg text-xs font-semibold bg-brand-600 text-white";

  if (floor === 'all') {
    renderShopsGrid(globalShops);
  } else {
    renderShopsGrid(globalShops.filter(s => s.floor === floor));
  }
}

async function handleShopSubmit(e) {
  e.preventDefault();
  const payload = {
    shop_name: document.getElementById("shop-name").value.trim(),
    category: document.getElementById("shop-category").value,
    floor: document.getElementById("shop-floor").value,
    contact_no: document.getElementById("shop-contact").value.trim(),
    tenant_name: document.getElementById("tenant-name").value.trim(),
    monthly_rent: parseFloat(document.getElementById("monthly-rent").value || 5000)
  };

  try {
    const res = await fetch("/api/shops", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload)
    });
    const result = await res.json();
    if (result.success) {
      showToast("Shop and Lease created successfully!", "success");
      closeModal("add-shop-modal");
      loadShopsData();
      populateDropdowns();
    } else {
      showToast(`Error: ${result.error}`, "error");
    }
  } catch (err) {
    showToast(`Error adding shop: ${err}`, "error");
  }
}

// --------------------------------------------------------------------
// 4. PRODUCTS & INVENTORY
// --------------------------------------------------------------------
async function loadProductsData() {
  try {
    const res = await fetch("/api/products");
    const data = await res.json();
    if (!data.success) return;

    globalProducts = data.products;
    renderProductsTable(globalProducts);
  } catch (err) {
    console.error("Error loading products:", err);
  }
}

function renderProductsTable(products) {
  const tbody = document.getElementById("products-table-body");
  if (!products || products.length === 0) {
    tbody.innerHTML = `<tr><td colspan="7" class="text-center py-6 text-xs text-slate-400">No products matching criteria.</td></tr>`;
    return;
  }

  tbody.innerHTML = products.map(p => {
    let stockBadge = `<span class="text-[11px] px-2 py-0.5 rounded-full font-semibold bg-emerald-100 text-emerald-800">In Stock</span>`;
    if (p.stock_quantity <= 0) {
      stockBadge = `<span class="text-[11px] px-2 py-0.5 rounded-full font-semibold bg-rose-100 text-rose-800">Out of Stock</span>`;
    } else if (p.stock_quantity <= 15) {
      stockBadge = `<span class="text-[11px] px-2 py-0.5 rounded-full font-semibold bg-amber-100 text-amber-800">Low Stock (${p.stock_quantity})</span>`;
    }

    return `
      <tr class="hover:bg-slate-50/80 transition">
        <td class="py-3 px-4 font-semibold text-slate-800">${escapeHtml(p.product_name)}</td>
        <td class="py-3 px-4 text-slate-600 text-xs">${escapeHtml(p.shop_name)}</td>
        <td class="py-3 px-4 text-slate-500 text-xs">${escapeHtml(p.category)}</td>
        <td class="py-3 px-4 text-right font-mono font-bold text-slate-900">${formatCurrency(p.price)}</td>
        <td class="py-3 px-4 text-center font-mono font-semibold">${p.stock_quantity}</td>
        <td class="py-3 px-4 text-center">${stockBadge}</td>
        <td class="py-3 px-4 text-right">
          <div class="inline-flex items-center space-x-1">
            <button onclick="quickUpdateStock(${p.product_id}, ${p.stock_quantity - 5})" class="px-2 py-1 bg-slate-100 hover:bg-slate-200 text-slate-700 rounded text-xs">&minus;5</button>
            <button onclick="quickUpdateStock(${p.product_id}, ${p.stock_quantity + 10})" class="px-2 py-1 bg-brand-50 hover:bg-brand-100 text-brand-700 rounded text-xs">&plus;10</button>
          </div>
        </td>
      </tr>
    `;
  }).join("");
}

function filterProductsTable() {
  const query = document.getElementById("product-search-input").value.toLowerCase();
  const shopFilter = document.getElementById("product-shop-filter").value;

  const filtered = globalProducts.filter(p => {
    const matchesSearch = p.product_name.toLowerCase().includes(query) || p.category.toLowerCase().includes(query);
    const matchesShop = shopFilter === 'all' || p.shop_id.toString() === shopFilter;
    return matchesSearch && matchesShop;
  });

  renderProductsTable(filtered);
}

async function quickUpdateStock(productId, newStock) {
  if (newStock < 0) newStock = 0;
  try {
    const res = await fetch(`/api/products/${productId}`, {
      method: "PUT",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ stock_quantity: newStock })
    });
    const result = await res.json();
    if (result.success) {
      loadProductsData();
      showToast("Inventory stock updated!", "success");
    }
  } catch (err) {
    showToast(`Error updating stock: ${err}`, "error");
  }
}

async function handleProductSubmit(e) {
  e.preventDefault();
  const payload = {
    shop_id: parseInt(document.getElementById("prod-shop-id").value),
    product_name: document.getElementById("prod-name").value.trim(),
    category: document.getElementById("prod-category").value.trim(),
    price: parseFloat(document.getElementById("prod-price").value),
    stock_quantity: parseInt(document.getElementById("prod-stock").value || 20)
  };

  try {
    const res = await fetch("/api/products", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload)
    });
    const result = await res.json();
    if (result.success) {
      showToast("Product added to catalog!", "success");
      closeModal("add-product-modal");
      loadProductsData();
    } else {
      showToast(`Error: ${result.error}`, "error");
    }
  } catch (err) {
    showToast(`Error: ${err}`, "error");
  }
}

async function handleOfferSubmit(e) {
  e.preventDefault();
  const payload = {
    shop_id: parseInt(document.getElementById("offer-shop-id").value),
    offer_name: document.getElementById("offer-name").value.trim(),
    discount_percentage: parseFloat(document.getElementById("offer-pct").value),
    start_date: document.getElementById("offer-start").value,
    end_date: document.getElementById("offer-end").value
  };

  try {
    const res = await fetch("/api/offers", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload)
    });
    const result = await res.json();
    if (result.success) {
      showToast("Offer published successfully!", "success");
      closeModal("add-offer-modal");
    } else {
      showToast(`Error: ${result.error}`, "error");
    }
  } catch (err) {
    showToast(`Error: ${err}`, "error");
  }
}

// --------------------------------------------------------------------
// 5. CUSTOMER & MEMBERSHIP
// --------------------------------------------------------------------
async function loadCustomersData() {
  try {
    const res = await fetch("/api/customers");
    const data = await res.json();
    if (!data.success) return;

    globalCustomers = data.customers;
    renderCustomersTable(globalCustomers);
    populateCustomerDropdowns();
  } catch (err) {
    console.error("Error loading customers:", err);
  }
}

function renderCustomersTable(customers) {
  const tbody = document.getElementById("customers-table-body");
  if (!customers || customers.length === 0) {
    tbody.innerHTML = `<tr><td colspan="8" class="text-center py-6 text-xs text-slate-400">No customers registered yet.</td></tr>`;
    return;
  }

  tbody.innerHTML = customers.map(c => `
    <tr class="hover:bg-slate-50/80 transition">
      <td class="py-3 px-4">
        <p class="font-bold text-slate-800">${escapeHtml(c.customer_name)}</p>
        <p class="text-[11px] text-slate-400 font-mono">Reg: ${c.registration_date}</p>
      </td>
      <td class="py-3 px-4 text-xs font-mono">
        <div>${escapeHtml(c.phone)}</div>
        <div class="text-slate-400">${escapeHtml(c.email || 'No email')}</div>
      </td>
      <td class="py-3 px-4">
        <span class="text-xs px-2.5 py-0.5 rounded-full font-semibold ${getMembershipBadgeClass(c.membership_type)}">
          ${escapeHtml(c.membership_type)}
        </span>
      </td>
      <td class="py-3 px-4 text-center font-mono font-bold text-brand-600">${c.points}</td>
      <td class="py-3 px-4 text-center font-mono font-semibold">${c.order_count}</td>
      <td class="py-3 px-4 text-right font-mono font-bold text-slate-900">${formatCurrency(c.total_spent)}</td>
      <td class="py-3 px-4 text-center">
        ${c.is_returning ? '<span class="text-[10px] bg-emerald-100 text-emerald-800 font-bold px-2 py-0.5 rounded-full">Returning</span>' : '<span class="text-[10px] bg-slate-100 text-slate-600 px-2 py-0.5 rounded-full">New</span>'}
      </td>
      <td class="py-3 px-4 text-right">
        <button onclick="viewCustomerProfile(${c.customer_id})" class="px-2.5 py-1 bg-brand-50 hover:bg-brand-100 text-brand-700 rounded-lg text-xs font-semibold transition">
          Activity Ledger
        </button>
      </td>
    </tr>
  `).join("");
}

async function viewCustomerProfile(cid) {
  try {
    const res = await fetch(`/api/customers/${cid}`);
    const data = await res.json();
    if (!data.success) return;

    const c = data.customer;
    const content = document.getElementById("customer-profile-content");

    content.innerHTML = `
      <div class="bg-slate-50 p-4 rounded-xl border border-slate-200 flex justify-between items-center">
        <div>
          <h4 class="font-bold text-slate-800 text-lg">${escapeHtml(c.customer_name)}</h4>
          <p class="text-xs text-slate-500 font-mono">${escapeHtml(c.phone)} | ${escapeHtml(c.email || 'N/A')}</p>
        </div>
        <div class="text-right">
          <span class="text-xs px-2.5 py-1 rounded-full font-bold ${getMembershipBadgeClass(c.membership_type)}">
            ${escapeHtml(c.membership_type)} Member
          </span>
          <p class="text-xs font-mono font-bold text-brand-600 mt-1">${c.points} Loyalty Points</p>
        </div>
      </div>

      <!-- Purchases Ledger -->
      <div>
        <h5 class="text-xs font-bold uppercase tracking-wider text-slate-500 mb-2">Purchase Transactions (${data.purchases.length})</h5>
        <div class="border border-slate-200 rounded-xl overflow-hidden max-h-44 overflow-y-auto">
          <table class="w-full text-xs text-left">
            <thead class="bg-slate-100 font-semibold text-slate-600">
              <tr>
                <th class="py-2 px-3">Order ID</th>
                <th class="py-2 px-3">Date</th>
                <th class="py-2 px-3">Shop</th>
                <th class="py-2 px-3 text-right">Amount</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-slate-100">
              ${data.purchases.length === 0 ? '<tr><td colspan="4" class="text-center py-3 text-slate-400">No purchases</td></tr>' : data.purchases.map(p => `
                <tr>
                  <td class="py-1.5 px-3 font-mono font-semibold">#${p.purchase_id}</td>
                  <td class="py-1.5 px-3 font-mono text-slate-500">${p.purchase_date}</td>
                  <td class="py-1.5 px-3">${escapeHtml(p.shop_name)}</td>
                  <td class="py-1.5 px-3 text-right font-mono font-bold text-slate-900">${formatCurrency(p.total_amount)}</td>
                </tr>
              `).join("")}
            </tbody>
          </table>
        </div>
      </div>

      <!-- Registered Vehicles -->
      <div>
        <h5 class="text-xs font-bold uppercase tracking-wider text-slate-500 mb-2">Registered Vehicles (${data.vehicles.length})</h5>
        <div class="flex flex-wrap gap-2">
          ${data.vehicles.length === 0 ? '<p class="text-xs text-slate-400 italic">No vehicles registered</p>' : data.vehicles.map(v => `
            <span class="px-2.5 py-1 bg-slate-100 border border-slate-200 rounded-lg text-xs font-mono font-semibold text-slate-700">
              <i class="fa-solid fa-car text-brand-500 mr-1"></i> ${escapeHtml(v.vehicle_number)} (${v.vehicle_type})
            </span>
          `).join("")}
        </div>
      </div>
    `;

    openModal("customer-profile-modal");
  } catch (err) {
    console.error("Error viewing profile:", err);
  }
}

async function handleCustomerSubmit(e) {
  e.preventDefault();
  const payload = {
    customer_name: document.getElementById("cust-name").value.trim(),
    phone: document.getElementById("cust-phone").value.trim(),
    email: document.getElementById("cust-email").value.trim(),
    membership_type: document.getElementById("cust-membership").value
  };

  try {
    const res = await fetch("/api/customers", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload)
    });
    const result = await res.json();
    if (result.success) {
      showToast("Customer registered successfully!", "success");
      closeModal("add-customer-modal");
      loadCustomersData();
    } else {
      showToast(`Error: ${result.error}`, "error");
    }
  } catch (err) {
    showToast(`Error registering customer: ${err}`, "error");
  }
}

// --------------------------------------------------------------------
// 6. SMART PARKING
// --------------------------------------------------------------------
let allParkingSlots = [];
async function loadParkingData() {
  try {
    const res = await fetch("/api/parking/slots");
    const data = await res.json();
    if (!data.success) return;

    allParkingSlots = data.slots;
    renderParkingSlots(allParkingSlots);
    loadActiveParkedVehicles();
  } catch (err) {
    console.error("Error loading parking:", err);
  }
}

function renderParkingSlots(slots) {
  const grid = document.getElementById("parking-slots-grid");
  if (!slots || slots.length === 0) {
    grid.innerHTML = `<p class="col-span-8 text-center py-8 text-xs text-slate-400">No parking slots in this floor.</p>`;
    return;
  }

  grid.innerHTML = slots.map(s => {
    let statusClass = "bg-emerald-50 border-emerald-300 text-emerald-800 hover:bg-emerald-100";
    let statusBadge = "Available";
    let icon = "fa-car";
    if (s.slot_vehicle_type === '2-Wheeler') icon = "fa-motorcycle";
    if (s.slot_vehicle_type === 'EV') icon = "fa-charging-station";

    if (s.status === 'Occupied') {
      statusClass = "bg-rose-50 border-rose-300 text-rose-800 shadow-sm";
      statusBadge = "Occupied";
    } else if (s.status === 'Reserved') {
      statusClass = "bg-amber-50 border-amber-300 text-amber-800";
      statusBadge = "Reserved";
    }

    return `
      <div class="parking-slot p-3 rounded-xl border ${statusClass} flex flex-col justify-between h-32 transition">
        <div class="flex justify-between items-start">
          <span class="font-mono font-bold text-xs">${escapeHtml(s.slot_number)}</span>
          <i class="fa-solid ${icon} text-sm opacity-70"></i>
        </div>

        <div class="my-1">
          ${s.status === 'Occupied' ? `
            <p class="font-mono font-bold text-xs uppercase tracking-tight truncate">${escapeHtml(s.vehicle_number || 'PARKED')}</p>
            <p class="text-[10px] text-slate-500 truncate">${escapeHtml(s.customer_name || 'Guest')}</p>
          ` : `
            <p class="text-xs text-emerald-700 font-semibold">Vacant</p>
            <p class="text-[10px] text-slate-500">${s.slot_vehicle_type}</p>
          `}
        </div>

        <div class="text-[10px] uppercase font-bold tracking-wider opacity-80 border-t border-current/20 pt-1 flex justify-between items-center">
          <span>${s.floor}</span>
          <span>${statusBadge}</span>
        </div>
      </div>
    `;
  }).join("");
}

function switchParkingFloor(floor) {
  document.querySelectorAll(".parking-floor-btn").forEach(btn => {
    btn.className = "parking-floor-btn px-3 py-1.5 rounded-lg text-xs font-semibold bg-white border border-slate-200 text-slate-600";
  });
  const btn = document.getElementById(`btn-parking-${floor}`);
  if (btn) btn.className = "parking-floor-btn px-3 py-1.5 rounded-lg text-xs font-semibold bg-brand-600 text-white";

  if (floor === 'all') {
    renderParkingSlots(allParkingSlots);
  } else {
    renderParkingSlots(allParkingSlots.filter(s => s.floor === floor));
  }
}

async function loadActiveParkedVehicles() {
  const select = document.getElementById("park-exit-select");
  const occupiedSlots = allParkingSlots.filter(s => s.status === 'Occupied' && s.entry_id);
  
  if (occupiedSlots.length === 0) {
    select.innerHTML = `<option value="">No vehicles currently parked</option>`;
    return;
  }
  select.innerHTML = occupiedSlots.map(s => `
    <option value="${s.entry_id}">${s.slot_number} - Plate: ${s.vehicle_number} (${s.slot_vehicle_type})</option>
  `).join("");
}

async function handleParkingEntrySubmit(e) {
  e.preventDefault();
  const payload = {
    vehicle_number: document.getElementById("park-veh-num").value.trim(),
    vehicle_type: document.getElementById("park-veh-type").value,
    customer_id: document.getElementById("park-cust-id").value ? parseInt(document.getElementById("park-cust-id").value) : null
  };

  try {
    const res = await fetch("/api/parking/entry", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload)
    });
    const result = await res.json();
    if (result.success) {
      showToast("Vehicle checked in! Slot assigned.", "success");
      closeModal("parking-entry-modal");
      loadParkingData();
      loadDashboardStats();
    } else {
      showToast(`Error: ${result.error}`, "error");
    }
  } catch (err) {
    showToast(`Error: ${err}`, "error");
  }
}

async function handleParkingExitSubmit(e) {
  e.preventDefault();
  const entryId = document.getElementById("park-exit-select").value;
  if (!entryId) {
    showToast("Please select a vehicle to check out!", "warning");
    return;
  }

  try {
    const res = await fetch("/api/parking/exit", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ entry_id: parseInt(entryId) })
    });
    const result = await res.json();
    if (result.success) {
      showToast(`Check-out complete! Duration: ${result.duration_hours}h, Fee: ${formatCurrency(result.fee)}`, "success");
      closeModal("parking-exit-modal");
      loadParkingData();
      loadDashboardStats();
    } else {
      showToast(`Error: ${result.error}`, "error");
    }
  } catch (err) {
    showToast(`Error: ${err}`, "error");
  }
}

// --------------------------------------------------------------------
// 7. MALL EVENTS
// --------------------------------------------------------------------
async function loadEventsData() {
  try {
    const res = await fetch("/api/events");
    const data = await res.json();
    if (!data.success) return;

    const grid = document.getElementById("events-grid");
    if (data.events.length === 0) {
      grid.innerHTML = `<p class="col-span-3 text-center py-8 text-xs text-slate-400">No scheduled events.</p>`;
      return;
    }

    grid.innerHTML = data.events.map(ev => {
      const pct = Math.min(100, ev.occupancy_percentage || 0);
      return `
        <div class="bg-white rounded-2xl border border-slate-200/80 p-5 shadow-sm space-y-4 flex flex-col justify-between">
          <div>
            <div class="flex justify-between items-start">
              <span class="text-xs font-mono font-semibold text-brand-600 bg-brand-50 px-2.5 py-0.5 rounded-full border border-brand-100">
                ${ev.event_date}
              </span>
              <span class="text-xs text-slate-500 font-mono">${ev.start_time.substring(0, 5)} - ${ev.end_time.substring(0, 5)}</span>
            </div>

            <h4 class="font-bold text-slate-800 text-base mt-2">${escapeHtml(ev.event_name)}</h4>
            <p class="text-xs text-slate-500 mt-1 flex items-center space-x-1">
              <i class="fa-solid fa-location-pin text-slate-400"></i>
              <span>${escapeHtml(ev.location)}</span>
            </p>
          </div>

          <!-- Capacity Bar -->
          <div class="space-y-1.5 pt-2 border-t border-slate-100">
            <div class="flex justify-between text-xs font-semibold">
              <span class="text-slate-600">Registrations: ${ev.total_registered} / ${ev.capacity}</span>
              <span class="text-brand-600">${pct}%</span>
            </div>
            <div class="w-full bg-slate-100 rounded-full h-2 overflow-hidden">
              <div class="bg-brand-600 h-2 rounded-full transition-all" style="width: ${pct}%"></div>
            </div>
            <div class="flex justify-between text-[11px] text-slate-400">
              <span>Attended: ${ev.total_attended}</span>
              <span>Seats Left: ${ev.remaining_seats}</span>
            </div>
          </div>

          <div class="pt-2">
            <button onclick="openEventRsvp(${ev.event_id}, '${escapeHtml(ev.event_name)}')" class="w-full py-2 bg-brand-50 hover:bg-brand-100 text-brand-700 rounded-xl text-xs font-bold transition flex items-center justify-center space-x-1.5">
              <i class="fa-solid fa-user-plus"></i>
              <span>Register Customer</span>
            </button>
          </div>
        </div>
      `;
    }).join("");
  } catch (err) {
    console.error("Error loading events:", err);
  }
}

function openEventRsvp(eventId, eventTitle) {
  document.getElementById("rsvp-event-id").value = eventId;
  document.getElementById("rsvp-event-title").textContent = `Event: ${eventTitle}`;
  populateCustomerDropdowns();
  openModal("event-rsvp-modal");
}

async function handleEventRsvpSubmit(e) {
  e.preventDefault();
  const eventId = document.getElementById("rsvp-event-id").value;
  const customerId = document.getElementById("rsvp-customer-id").value;

  try {
    const res = await fetch(`/api/events/${eventId}/register`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ customer_id: parseInt(customerId) })
    });
    const result = await res.json();
    if (result.success) {
      showToast("Customer registered for event!", "success");
      closeModal("event-rsvp-modal");
      loadEventsData();
    } else {
      showToast(`Error: ${result.error}`, "error");
    }
  } catch (err) {
    showToast(`Error: ${err}`, "error");
  }
}

async function handleEventSubmit(e) {
  e.preventDefault();
  const payload = {
    event_name: document.getElementById("event-name").value.trim(),
    event_date: document.getElementById("event-date").value,
    capacity: parseInt(document.getElementById("event-capacity").value),
    start_time: document.getElementById("event-start").value,
    end_time: document.getElementById("event-end").value,
    location: document.getElementById("event-location").value.trim()
  };

  try {
    const res = await fetch("/api/events", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload)
    });
    const result = await res.json();
    if (result.success) {
      showToast("New event published!", "success");
      closeModal("add-event-modal");
      loadEventsData();
    } else {
      showToast(`Error: ${result.error}`, "error");
    }
  } catch (err) {
    showToast(`Error: ${err}`, "error");
  }
}

// --------------------------------------------------------------------
// 8. COMPLAINTS & MAINTENANCE
// --------------------------------------------------------------------
async function loadSupportData() {
  try {
    const [cRes, mRes, eRes] = await Promise.all([
      fetch("/api/complaints"),
      fetch("/api/maintenance"),
      fetch("/api/employees")
    ]);
    const cData = await cRes.json();
    const mData = await mRes.json();
    const eData = await eRes.json();

    const employees = eData.success ? eData.employees : [];

    // Render Complaints
    const cList = document.getElementById("complaints-list");
    document.getElementById("complaints-count-badge").textContent = cData.complaints.length;

    cList.innerHTML = cData.complaints.map(c => `
      <div class="p-3.5 bg-slate-50 border border-slate-200 rounded-xl space-y-2">
        <div class="flex justify-between items-start">
          <div class="flex items-center space-x-2">
            <span class="text-xs px-2 py-0.5 rounded font-semibold ${getPriorityBadgeClass(c.priority)}">
              ${c.priority}
            </span>
            <span class="text-xs font-semibold text-slate-700">${escapeHtml(c.complaint_type)}</span>
          </div>
          <span class="text-[11px] px-2 py-0.5 rounded-full font-bold ${getStatusBadgeClass(c.status)}">
            ${c.status}
          </span>
        </div>

        <p class="text-xs text-slate-600 leading-relaxed">${escapeHtml(c.description)}</p>

        <div class="flex justify-between items-center text-[11px] text-slate-400 pt-1 border-t border-slate-200/60">
          <span>By: ${escapeHtml(c.customer_name)} | ${c.complaint_date.substring(0, 10)}</span>
          <span>Assigned: <strong class="text-slate-700">${escapeHtml(c.assigned_to || 'None')}</strong></span>
        </div>

        ${c.status !== 'Resolved' ? `
          <div class="flex justify-end space-x-2 pt-1">
            <button onclick="resolveComplaint(${c.complaint_id})" class="px-2.5 py-1 bg-emerald-100 hover:bg-emerald-200 text-emerald-800 rounded text-xs font-bold transition">
              <i class="fa-solid fa-check mr-1"></i> Resolve Ticket
            </button>
          </div>
        ` : ''}
      </div>
    `).join("");

    // Render Maintenance
    const mList = document.getElementById("maintenance-list");
    document.getElementById("maintenance-count-badge").textContent = mData.maintenance.length;

    mList.innerHTML = mData.maintenance.map(m => `
      <div class="p-3.5 bg-slate-50 border border-slate-200 rounded-xl space-y-2">
        <div class="flex justify-between items-start">
          <span class="text-xs font-bold text-slate-800">${escapeHtml(m.issue_type)}</span>
          <span class="text-[11px] px-2 py-0.5 rounded-full font-bold ${getStatusBadgeClass(m.status)}">
            ${m.status}
          </span>
        </div>

        <p class="text-xs text-slate-600 leading-relaxed">${escapeHtml(m.description)}</p>

        <div class="flex justify-between items-center text-[11px] text-slate-400 pt-1 border-t border-slate-200/60">
          <span>Logged: ${m.request_date.substring(0, 10)}</span>
          <span>Technician: <strong class="text-slate-700">${escapeHtml(m.assigned_technician || 'Pending')}</strong></span>
        </div>

        ${m.status !== 'Completed' ? `
          <div class="flex justify-end space-x-2 pt-1">
            <button onclick="completeMaintenance(${m.request_id})" class="px-2.5 py-1 bg-blue-100 hover:bg-blue-200 text-blue-800 rounded text-xs font-bold transition">
              <i class="fa-solid fa-wrench mr-1"></i> Mark Completed
            </button>
          </div>
        ` : ''}
      </div>
    `).join("");

  } catch (err) {
    console.error("Error loading support data:", err);
  }
}

async function resolveComplaint(cid) {
  try {
    const res = await fetch(`/api/complaints/${cid}/status`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ status: "Resolved" })
    });
    const result = await res.json();
    if (result.success) {
      showToast("Complaint resolved!", "success");
      loadSupportData();
      loadDashboardStats();
    }
  } catch (err) {
    showToast(`Error: ${err}`, "error");
  }
}

async function completeMaintenance(mid) {
  try {
    const res = await fetch(`/api/maintenance/${mid}/status`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ status: "Completed" })
    });
    const result = await res.json();
    if (result.success) {
      showToast("Maintenance task completed!", "success");
      loadSupportData();
      loadDashboardStats();
    }
  } catch (err) {
    showToast(`Error: ${err}`, "error");
  }
}

async function handleComplaintSubmit(e) {
  e.preventDefault();
  const payload = {
    customer_id: parseInt(document.getElementById("comp-customer-id").value),
    complaint_type: document.getElementById("comp-type").value,
    priority: document.getElementById("comp-priority").value,
    description: document.getElementById("comp-desc").value.trim()
  };

  try {
    const res = await fetch("/api/complaints", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload)
    });
    const result = await res.json();
    if (result.success) {
      showToast("Complaint ticket logged!", "success");
      closeModal("complaint-modal");
      loadSupportData();
      loadDashboardStats();
    }
  } catch (err) {
    showToast(`Error: ${err}`, "error");
  }
}

async function handleMaintenanceSubmit(e) {
  e.preventDefault();
  const custId = document.getElementById("maint-cust-id").value;
  const payload = {
    customer_id: custId ? parseInt(custId) : null,
    issue_type: document.getElementById("maint-type").value,
    description: document.getElementById("maint-desc").value.trim()
  };

  try {
    const res = await fetch("/api/maintenance", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload)
    });
    const result = await res.json();
    if (result.success) {
      showToast("Maintenance work order created!", "success");
      closeModal("maintenance-modal");
      loadSupportData();
      loadDashboardStats();
    }
  } catch (err) {
    showToast(`Error: ${err}`, "error");
  }
}

// --------------------------------------------------------------------
// 9. 10 DBMS ANALYTICAL CHARTS (CASE STUDY SPEC)
// --------------------------------------------------------------------
async function loadAnalyticsData() {
  try {
    const res = await fetch("/api/analytics/all");
    const data = await res.json();
    if (!data.success) return;

    const an = data.analytics;

    // Helper to safely destroy and re-create charts
    const buildChart = (canvasId, config) => {
      if (chartsInstances[canvasId]) {
        chartsInstances[canvasId].destroy();
      }
      const ctx = document.getElementById(canvasId).getContext("2d");
      chartsInstances[canvasId] = new Chart(ctx, config);
    };

    // 1. Sales by Shop (Bar Chart)
    buildChart("chart-sales-shop", {
      type: "bar",
      data: {
        labels: an.sales_by_shop.map(s => s.shop_name),
        datasets: [{
          label: "Total Sales Revenue ($)",
          data: an.sales_by_shop.map(s => s.total_revenue),
          backgroundColor: "#4f46e5",
          borderRadius: 6
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: { legend: { display: false } },
        scales: { y: { beginAtZero: true } }
      }
    });

    // 2. Popular Categories (Doughnut Chart)
    buildChart("chart-popular-categories", {
      type: "doughnut",
      data: {
        labels: an.popular_categories.map(c => c.category),
        datasets: [{
          data: an.popular_categories.map(c => c.total_units_sold),
          backgroundColor: ["#6366f1", "#10b981", "#f59e0b", "#ec4899", "#8b5cf6", "#06b6d4", "#84cc16"]
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: { legend: { position: "right", labels: { boxWidth: 12, font: { size: 10 } } } }
      }
    });

    // 3. Customer Purchase Patterns (Bar Chart)
    buildChart("chart-customer-patterns", {
      type: "bar",
      data: {
        labels: an.customer_patterns.map(p => p.membership_type),
        datasets: [{
          label: "Avg Spend Per Customer ($)",
          data: an.customer_patterns.map(p => p.avg_spent_per_customer),
          backgroundColor: "#059669",
          borderRadius: 6
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        scales: { y: { beginAtZero: true } }
      }
    });

    // 4. Parking Peak Hours (Line Chart)
    buildChart("chart-parking-peak", {
      type: "line",
      data: {
        labels: an.parking_peak_hours.map(h => h.hour_of_day),
        datasets: [{
          label: "Vehicles Checked In",
          data: an.parking_peak_hours.map(h => h.vehicle_count),
          borderColor: "#2563eb",
          backgroundColor: "rgba(37, 99, 235, 0.1)",
          fill: true,
          tension: 0.3
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        scales: { y: { beginAtZero: true, ticks: { stepSize: 1 } } }
      }
    });

    // 5. Event Attendance vs Capacity (Bar Chart)
    buildChart("chart-events-attendance", {
      type: "bar",
      data: {
        labels: an.event_stats.map(e => e.event_name.length > 20 ? e.event_name.substring(0, 18) + '...' : e.event_name),
        datasets: [
          { label: "Max Capacity", data: an.event_stats.map(e => e.capacity), backgroundColor: "#cbd5e1", borderRadius: 4 },
          { label: "Registered RSVPs", data: an.event_stats.map(e => e.registered), backgroundColor: "#6366f1", borderRadius: 4 }
        ]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        scales: { y: { beginAtZero: true } }
      }
    });

    // 6. Common Complaints Breakdown (Doughnut Chart)
    buildChart("chart-complaints-type", {
      type: "doughnut",
      data: {
        labels: an.common_complaints.map(c => c.complaint_type),
        datasets: [{
          data: an.common_complaints.map(c => c.total_complaints),
          backgroundColor: ["#f59e0b", "#ef4444", "#3b82f6", "#10b981", "#8b5cf6"]
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: { legend: { position: "right", labels: { boxWidth: 12, font: { size: 10 } } } }
      }
    });

    // 7. Pending Maintenance (Bar Chart)
    buildChart("chart-maintenance-issues", {
      type: "bar",
      data: {
        labels: an.pending_maintenance.map(m => m.issue_type),
        datasets: [
          { label: "Completed", data: an.pending_maintenance.map(m => m.completed_count), backgroundColor: "#10b981", borderRadius: 4 },
          { label: "Pending / In Progress", data: an.pending_maintenance.map(m => m.unassigned_pending + m.in_progress_count), backgroundColor: "#f97316", borderRadius: 4 }
        ]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        scales: { y: { beginAtZero: true, ticks: { stepSize: 1 } } }
      }
    });

    // 8. Lease Status (Pie Chart)
    buildChart("chart-lease-status", {
      type: "pie",
      data: {
        labels: an.lease_summary.map(l => l.lease_status),
        datasets: [{
          data: an.lease_summary.map(l => l.lease_count),
          backgroundColor: ["#10b981", "#f59e0b", "#ef4444", "#64748b"]
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: { legend: { position: "right" } }
      }
    });

    // 9. Payment Methods Usage (Doughnut Chart)
    buildChart("chart-payment-methods", {
      type: "doughnut",
      data: {
        labels: an.payment_methods.map(p => p.payment_method),
        datasets: [{
          data: an.payment_methods.map(p => p.total_collected),
          backgroundColor: ["#4f46e5", "#10b981", "#06b6d4", "#f59e0b", "#8b5cf6"]
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: { legend: { position: "right" } }
      }
    });

    // 10. Returning Customers vs First Time (Bar Chart)
    buildChart("chart-returning-customers", {
      type: "bar",
      data: {
        labels: an.returning_customers.map(r => r.customer_type),
        datasets: [{
          label: "Total Sales Contribution ($)",
          data: an.returning_customers.map(r => r.total_spent),
          backgroundColor: ["#8b5cf6", "#38bdf8"],
          borderRadius: 6
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        scales: { y: { beginAtZero: true } }
      }
    });

  } catch (err) {
    console.error("Error loading analytics:", err);
  }
}

// --------------------------------------------------------------------
// 10. DBMS SQL CONSOLE & SCHEMA INTROSPECTION
// --------------------------------------------------------------------
function loadSampleQuery(queryNumber) {
  const input = document.getElementById("sql-console-input");
  switch (queryNumber) {
    case 1:
      // Multi-table Join
      input.value = `SELECT s.shop_name, s.category, s.floor, t.tenant_name, l.monthly_rent,
       COUNT(p.purchase_id) AS total_sales_orders,
       COALESCE(SUM(p.total_amount), 0.0) AS gross_revenue
FROM SHOP s
JOIN TENANT t ON l.tenant_id = t.tenant_id
JOIN LEASE l ON s.shop_id = l.shop_id
LEFT JOIN PURCHASE p ON s.shop_id = p.shop_id
GROUP BY s.shop_id
ORDER BY gross_revenue DESC;`;
      break;

    case 2:
      // Group By & Having (Loyal High-Spenders)
      input.value = `SELECT c.customer_name, c.phone, m.membership_type, m.points,
       COUNT(p.purchase_id) as total_purchases,
       SUM(p.total_amount) as total_spent
FROM CUSTOMER c
JOIN MEMBERSHIP m ON c.customer_id = m.customer_id
JOIN PURCHASE p ON c.customer_id = p.customer_id
GROUP BY c.customer_id
HAVING SUM(p.total_amount) >= 200.00
ORDER BY total_spent DESC;`;
      break;

    case 3:
      // Nested Subquery (Customer with Maximum Lifetime Spend)
      input.value = `SELECT customer_name, phone, email, registration_date
FROM CUSTOMER
WHERE customer_id = (
    SELECT customer_id
    FROM PURCHASE
    GROUP BY customer_id
    ORDER BY SUM(total_amount) DESC
    LIMIT 1
);`;
      break;

    case 4:
      // View 3: Parking Status
      input.value = `SELECT slot_number, floor, slot_vehicle_type, status, vehicle_number, customer_name
FROM vw_parking_status
ORDER BY floor, slot_number;`;
      break;

    case 5:
      // View 5: Unresolved Complaints
      input.value = `SELECT complaint_id, complaint_type, priority, status, customer_name, assigned_to, complaint_date
FROM vw_complaints_detail
WHERE status != 'Resolved';`;
      break;

    case 6:
      // Trigger Verification: Product stock test
      input.value = `SELECT product_id, product_name, category, price, stock_quantity
FROM PRODUCT
ORDER BY stock_quantity ASC
LIMIT 10;`;
      break;
  }
}

async function runConsoleQuery(explain = false) {
  const query = document.getElementById("sql-console-input").value.trim();
  const metaElem = document.getElementById("query-meta-info");
  const container = document.getElementById("query-results-container");

  if (!query) {
    showToast("Please enter an SQL query to execute!", "warning");
    return;
  }

  metaElem.innerHTML = `<i class="fa-solid fa-spinner fa-spin"></i> Executing query...`;

  try {
    const res = await fetch("/api/sql-console", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ query: query, explain: explain })
    });
    const result = await res.json();

    if (!result.success) {
      metaElem.innerHTML = `<span class="text-rose-600 font-bold">SQL Error in ${result.duration_ms}ms</span>`;
      container.innerHTML = `
        <div class="p-4 bg-rose-50 border border-rose-200 rounded-xl text-rose-800 text-xs font-mono">
          <p class="font-bold mb-1"><i class="fa-solid fa-triangle-exclamation"></i> Execution Failed:</p>
          <p>${escapeHtml(result.error)}</p>
        </div>
      `;
      return;
    }

    metaElem.innerHTML = `<span class="text-emerald-600 font-bold">${result.row_count} row(s) returned in ${result.duration_ms}ms</span>`;

    if (!result.columns || result.columns.length === 0 || !result.rows || result.rows.length === 0) {
      container.innerHTML = `<p class="text-xs text-slate-500 py-6 text-center italic">Query executed successfully. 0 rows returned.</p>`;
      return;
    }

    // Render Table
    container.innerHTML = `
      <table class="w-full text-left text-xs font-mono border border-slate-200 rounded-lg overflow-hidden">
        <thead class="bg-slate-100 text-slate-700 font-semibold border-b border-slate-200">
          <tr>
            ${result.columns.map(c => `<th class="py-2 px-3 border-r border-slate-200 last:border-r-0">${escapeHtml(c)}</th>`).join("")}
          </tr>
        </thead>
        <tbody class="divide-y divide-slate-100">
          ${result.rows.map(row => `
            <tr class="hover:bg-brand-50/40 transition">
              ${row.map(cell => `<td class="py-2 px-3 border-r border-slate-200/60 last:border-r-0 text-slate-800">${escapeHtml(cell !== null ? cell.toString() : 'NULL')}</td>`).join("")}
            </tr>
          `).join("")}
        </tbody>
      </table>
    `;

  } catch (err) {
    metaElem.innerHTML = `<span class="text-rose-600">Network Error</span>`;
    showToast(`Error: ${err}`, "error");
  }
}

async function loadSchemaBrowser() {
  try {
    const res = await fetch("/api/schema/tables");
    const data = await res.json();
    if (!data.success) return;

    const accordion = document.getElementById("schema-tables-accordion");
    accordion.innerHTML = data.schema.map((item, idx) => `
      <details class="bg-slate-50 border border-slate-200 rounded-xl overflow-hidden group">
        <summary class="p-3.5 flex justify-between items-center cursor-pointer select-none font-bold text-xs text-slate-800 hover:bg-slate-100 transition">
          <div class="flex items-center space-x-2">
            <span class="text-[10px] px-2 py-0.5 rounded font-mono uppercase ${item.type === 'view' ? 'bg-amber-100 text-amber-800' : 'bg-brand-100 text-brand-800'}">
              ${item.type}
            </span>
            <span class="font-mono text-sm">${escapeHtml(item.name)}</span>
          </div>
          <span class="text-slate-400 group-open:rotate-180 transition-transform">
            <i class="fa-solid fa-chevron-down text-xs"></i>
          </span>
        </summary>
        <div class="p-4 border-t border-slate-200 bg-white">
          <table class="w-full text-left text-xs font-mono">
            <thead class="border-b border-slate-200 text-slate-500 font-semibold">
              <tr>
                <th class="py-1 px-2">Column</th>
                <th class="py-1 px-2">Data Type</th>
                <th class="py-1 px-2">PK</th>
                <th class="py-1 px-2">Not Null</th>
                <th class="py-1 px-2">Default</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-slate-100">
              ${item.columns.map(c => `
                <tr>
                  <td class="py-1.5 px-2 font-bold ${c.pk ? 'text-indigo-600' : 'text-slate-800'}">${escapeHtml(c.name)}</td>
                  <td class="py-1.5 px-2 text-slate-600">${escapeHtml(c.type || 'TEXT')}</td>
                  <td class="py-1.5 px-2">${c.pk ? '<span class="text-indigo-600 font-bold">YES</span>' : '-'}</td>
                  <td class="py-1.5 px-2">${c.notnull ? '<span class="text-rose-600">YES</span>' : 'NO'}</td>
                  <td class="py-1.5 px-2 text-slate-400">${escapeHtml(c.dflt_value || '-')}</td>
                </tr>
              `).join("")}
            </tbody>
          </table>
        </div>
      </details>
    `).join("");

  } catch (err) {
    console.error("Error loading schema:", err);
  }
}

// --------------------------------------------------------------------
// DROPDOWNS & HELPERS
// --------------------------------------------------------------------
function populateDropdowns() {
  populateShopDropdowns();
  populateCustomerDropdowns();
}

function populateShopDropdowns() {
  const posSelect = document.getElementById("pos-shop-select");
  const prodShopSelect = document.getElementById("prod-shop-id");
  const offerShopSelect = document.getElementById("offer-shop-id");
  const filterSelect = document.getElementById("product-shop-filter");

  if (!globalShops || globalShops.length === 0) return;

  const options = globalShops.map(s => `<option value="${s.shop_id}">${escapeHtml(s.shop_name)} (${escapeHtml(s.floor)})</option>`).join("");

  if (posSelect && posSelect.children.length === 0) posSelect.innerHTML = options;
  if (prodShopSelect) prodShopSelect.innerHTML = options;
  if (offerShopSelect) offerShopSelect.innerHTML = options;
  if (filterSelect) {
    filterSelect.innerHTML = `<option value="all">All Shops</option>` + options;
  }
}

function populateCustomerDropdowns() {
  const posCustSelect = document.getElementById("pos-customer-select");
  const parkCustSelect = document.getElementById("park-cust-id");
  const compCustSelect = document.getElementById("comp-customer-id");
  const maintCustSelect = document.getElementById("maint-cust-id");
  const rsvpCustSelect = document.getElementById("rsvp-customer-id");

  if (!globalCustomers || globalCustomers.length === 0) return;

  const options = globalCustomers.map(c => `
    <option value="${c.customer_id}">${escapeHtml(c.customer_name)} (${c.membership_type} - ${c.points} pts)</option>
  `).join("");

  if (posCustSelect) posCustSelect.innerHTML = options;
  if (compCustSelect) compCustSelect.innerHTML = options;
  if (rsvpCustSelect) rsvpCustSelect.innerHTML = options;
  if (parkCustSelect) {
    parkCustSelect.innerHTML = `<option value="">Guest Visitor / Walk-in</option>` + options;
  }
  if (maintCustSelect) {
    maintCustSelect.innerHTML = `<option value="">Mall Staff Internal Inspection</option>` + options;
  }
}

// Modals
function openModal(id) {
  const m = document.getElementById(id);
  if (m) m.classList.remove("hidden");
}

function closeModal(id) {
  const m = document.getElementById(id);
  if (m) m.classList.add("hidden");
}

// Toast
function showToast(message, type = "info") {
  const container = document.getElementById("toast-container");
  const toast = document.createElement("div");

  let bg = "bg-slate-900 text-white";
  let icon = "fa-info-circle text-blue-400";
  if (type === "success") {
    bg = "bg-emerald-900 text-emerald-100 border border-emerald-700";
    icon = "fa-circle-check text-emerald-400";
  } else if (type === "error") {
    bg = "bg-rose-900 text-rose-100 border border-rose-700";
    icon = "fa-triangle-exclamation text-rose-400";
  } else if (type === "warning") {
    bg = "bg-amber-900 text-amber-100 border border-amber-700";
    icon = "fa-triangle-exclamation text-amber-400";
  }

  toast.className = `${bg} px-4 py-3 rounded-xl shadow-xl flex items-center space-x-2 text-xs font-semibold pointer-events-auto transition-all transform translate-y-2 opacity-0`;
  toast.innerHTML = `<i class="fa-solid ${icon}"></i> <span>${escapeHtml(message)}</span>`;

  container.appendChild(toast);
  setTimeout(() => {
    toast.classList.remove("translate-y-2", "opacity-0");
  }, 10);

  setTimeout(() => {
    toast.classList.add("opacity-0", "translate-y-2");
    setTimeout(() => toast.remove(), 300);
  }, 3500);
}

// Formatters
function formatCurrency(val) {
  const n = parseFloat(val) || 0;
  return `$${n.toFixed(2)}`;
}

function escapeHtml(str) {
  if (str === null || str === undefined) return '';
  return String(str)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;');
}

function getMembershipBadgeClass(tier) {
  switch (tier) {
    case 'Platinum': return 'bg-purple-100 text-purple-800 border border-purple-200';
    case 'Gold': return 'bg-amber-100 text-amber-800 border border-amber-200';
    case 'Silver': return 'bg-slate-200 text-slate-800 border border-slate-300';
    default: return 'bg-slate-100 text-slate-600 border border-slate-200';
  }
}

function getLeaseStatusClass(status) {
  switch (status) {
    case 'Active': return 'bg-emerald-100 text-emerald-800';
    case 'Pending Renewal': return 'bg-amber-100 text-amber-800';
    case 'Expired': return 'bg-rose-100 text-rose-800';
    default: return 'bg-slate-100 text-slate-600';
  }
}

function getPriorityBadgeClass(priority) {
  switch (priority) {
    case 'Urgent': return 'bg-rose-100 text-rose-800 border border-rose-300 font-bold';
    case 'High': return 'bg-amber-100 text-amber-800';
    case 'Medium': return 'bg-blue-100 text-blue-800';
    default: return 'bg-slate-100 text-slate-600';
  }
}

function getStatusBadgeClass(status) {
  switch (status) {
    case 'Resolved':
    case 'Completed': return 'bg-emerald-100 text-emerald-800';
    case 'In Progress': return 'bg-blue-100 text-blue-800';
    default: return 'bg-amber-100 text-amber-800';
  }
}

function getPaymentBadgeClass(method) {
  switch (method) {
    case 'Credit Card': return 'bg-indigo-100 text-indigo-800';
    case 'UPI': return 'bg-emerald-100 text-emerald-800';
    case 'Debit Card': return 'bg-blue-100 text-blue-800';
    case 'Cash': return 'bg-slate-100 text-slate-700';
    default: return 'bg-purple-100 text-purple-800';
  }
}

// --------------------------------------------------------------------
// LIVE SQL QUERY TRACER & AUDIT LOG (DBMS VIVA FEATURE)
// --------------------------------------------------------------------
async function openSqlTracerModal() {
  openModal('sql-tracer-modal');
  await fetchSqlLogs();
}

async function fetchSqlLogs() {
  try {
    const res = await fetch('/api/sql/logs');
    const data = await res.json();
    if (!data.success) return;

    const badge = document.getElementById('sql-tracer-engine-badge');
    if (badge) badge.textContent = `SQL Engine: ${data.engine.toUpperCase()}`;

    const counter = document.getElementById('sql-log-counter');
    if (counter) counter.textContent = data.logs.length;

    const list = document.getElementById('sql-tracer-list');
    if (!list) return;

    if (data.logs.length === 0) {
      list.innerHTML = `<p class="text-slate-400 py-6 text-center italic font-sans text-xs">No SQL queries executed yet. Perform actions like POS sale or parking to see real-time SQL execution.</p>`;
      return;
    }

    list.innerHTML = data.logs.map(log => {
      let typeBadge = 'bg-slate-100 text-slate-700';
      if (log.type === 'INSERT') typeBadge = 'bg-emerald-100 text-emerald-800 font-bold';
      else if (log.type === 'UPDATE') typeBadge = 'bg-amber-100 text-amber-800 font-bold';
      else if (log.type === 'DELETE') typeBadge = 'bg-rose-100 text-rose-800 font-bold';
      else if (log.type === 'SELECT') typeBadge = 'bg-blue-100 text-blue-800';
      else if (log.type === 'TRIGGER') typeBadge = 'bg-purple-100 text-purple-800 font-bold';

      return `
        <div class="p-3 bg-slate-900 text-slate-100 rounded-xl border border-slate-800 space-y-1.5 shadow-sm hover:border-brand-500 transition">
          <div class="flex justify-between items-center text-[10px] text-slate-400 border-b border-slate-800/80 pb-1">
            <div class="flex items-center space-x-2">
              <span class="px-1.5 py-0.5 rounded text-[10px] uppercase font-mono ${typeBadge}">${log.type}</span>
              <span class="font-mono text-slate-400">#${log.id} at ${log.timestamp}</span>
            </div>
            <span class="text-emerald-400 font-bold">${log.duration_ms} ms</span>
          </div>
          <div class="text-xs text-emerald-300 font-mono break-all leading-relaxed whitespace-pre-wrap">${escapeHtml(log.query)}</div>
          ${log.params && log.params.length > 0 ? `
            <div class="text-[10px] text-slate-400 pt-1 border-t border-slate-800">
              <span class="text-slate-500">Parameters:</span> <span class="text-slate-300">${escapeHtml(JSON.stringify(log.params))}</span>
            </div>
          ` : ''}
        </div>
      `;
    }).join('');
  } catch (err) {
    console.error('Error fetching SQL logs:', err);
  }
}

// Auto-refresh counter every 10 seconds
setInterval(async () => {
  try {
    const res = await fetch('/api/sql/logs');
    const data = await res.json();
    if (data.success) {
      const counter = document.getElementById('sql-log-counter');
      if (counter) counter.textContent = data.logs.length;
    }
  } catch (e) {}
}, 10000);

