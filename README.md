# Field Notes photo gallery

The site is static and can be published from this repository with GitHub Pages. Supabase provides admin sign-in, image storage, and photo metadata.

## Connect Supabase

1. Create a Supabase project.
2. In the Supabase SQL Editor, run the contents of `supabase-setup.sql`.
3. In Supabase Authentication, add an admin user. Do not add a public sign-up form to this site.
4. Copy that user's UUID from Authentication > Users, then add it to the admin allowlist in the SQL Editor:

   ```sql
   insert into public.gallery_admins (user_id)
   values ('PASTE-ADMIN-USER-UUID-HERE');
   ```

5. In Supabase project settings, copy the Project URL and the public anon/publishable key into `supabase-config.js`:

   ```js
   window.FIELD_NOTES_SUPABASE = {
     url: "https://your-project.supabase.co",
     anonKey: "your-public-anon-or-publishable-key"
   };
   ```

6. Commit the site files and enable GitHub Pages for the repository's root folder.
7. Open the published site and choose **Admin sign in** to add photos. Enter a direct, publicly reachable photo source URL, a title, an optional title destination URL, and comma-separated tags. The displayed title links to its destination when provided.

If you already ran the setup SQL, run the updated `supabase-setup.sql` again after changes. It adds `image_url` and makes the old `storage_path` optional. New entries store URL metadata in Supabase; their image files stay on the linked image host. Existing Storage-backed photos continue to display until you replace their source URL in **Edit photo**, which then removes the old Storage object. Signed-in admins can edit tags, replace image URLs, or remove photos from the gallery.

The public key is intended for browser use. The SQL policies make gallery metadata readable publicly but allow writes only for user IDs in `gallery_admins`. Never put a Supabase `service_role` or secret key in this repository. Photo source URLs and images are public because the gallery is public. Since new photos are no longer processed by the site, metadata and access are controlled by the external image host.