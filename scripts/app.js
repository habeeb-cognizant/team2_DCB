function showError(selector, message) {
  const $input = $(selector);
  $input.addClass('is-invalid');
  if ($input.next('.invalid-feedback').length === 0) {
    $input.after(`<div class="invalid-feedback">${message}</div>`);
  } else {
    $input.next('.invalid-feedback').text(message);
  }
}

function clearErrors(form) {
  $(form).find('.is-invalid').removeClass('is-invalid');
  $(form).find('.invalid-feedback').remove();
}

function isValidEmail(email) {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

function isValidPassword(pwd) {
  return /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[A-Za-z\d]{8,16}$/.test(pwd);
}

// LOGIN FORM
$('#loginForm').on('submit', function (e) {
  e.preventDefault();
  clearErrors(this);

  const email = $.trim($('#email').val());
  const password = $.trim($('#password').val());
  let valid = true;

  if (!email) {
    showError('#email', 'Email is required.');
    valid = false;
  } else if (!isValidEmail(email)) {
    showError('#email', 'Please enter a valid email address.');
    valid = false;
  }

  if (!password) {
    showError('#password', 'Password is required.');
    valid = false;
  } else if (!isValidPassword(password)) {
    showError('#password', 'Password must be 8-16 chars, include uppercase, lowercase, and number.');
    valid = false;
  }

  if (!valid) return;

  const $btn = $(this).find('button[type="submit"]');
  $btn.prop('disabled', true).html('<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> Logging in...');

  setTimeout(() => {
    // Store login email in sessionStorage to use in complaint-form
    sessionStorage.setItem('loggedInEmail', email);
    window.location.href = "complaint-form.html";
  }, 800);
});

// COMPLAINT FORM
$('#complaintForm').on('submit', function (e) {
  e.preventDefault();
  clearErrors(this);

  const category = $.trim($('#category').val());
  const description = $.trim($('#description').val());
  const email = sessionStorage.getItem('loggedInEmail');
  let valid = true;

  if (!category) {
    showError('#category', 'Please select a category.');
    valid = false;
  }

  if (!description || description.length < 10) {
    showError('#description', 'Description must be at least 10 characters.');
    valid = false;
  }

  if (!valid) return;

  // Save complaint to localStorage
  const complaint = {
    email,
    category,
    description,
    status: 'Pending'
  };

  const complaints = JSON.parse(localStorage.getItem('complaints')) || [];
  complaints.push(complaint);
  localStorage.setItem('complaints', JSON.stringify(complaints));

  const $btn = $(this).find('button[type="submit"]');
  $btn.prop('disabled', true).html('<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> Submitting...');

  setTimeout(() => {
    window.location.href = "status-tracking.html";
  }, 800);
});

// STATUS FORM
$('#statusForm').on('submit', function (e) {
  e.preventDefault();
  clearErrors(this);

  const input = $.trim($('#complaintId').val()).toLowerCase();
  const complaints = JSON.parse(localStorage.getItem('complaints')) || [];

  const found = complaints.find(c => c.email === input);

  let result = '';
  if (found) {
    result = `Your complaint is currently: <span class="badge bg-warning text-dark">${found.status}</span>`;
  } else {
    result = '<span class="text-danger">No matching complaint found.</span>';
  }

  $('#statusResult').html(`<p>${result}</p>`);
});
