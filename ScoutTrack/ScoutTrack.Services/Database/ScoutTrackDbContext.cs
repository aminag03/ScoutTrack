using Microsoft.EntityFrameworkCore;
using ScoutTrack.Services.Database.Entities;

namespace ScoutTrack.Services.Database
{
    public class ScoutTrackDbContext : DbContext
    {
        public ScoutTrackDbContext(DbContextOptions<ScoutTrackDbContext> options) : base(options) { }

        public enum BadgeStatus { NotStarted, InProgress, Completed }
        public enum FriendshipStatus { Pending, Accepted, Rejected }
        public enum Gender { Male, Female }
        public enum RegistrationStatus { Pending, Approved, Rejected, Cancelled, Completed }
        public enum Role { Member, TroopLeader, Admin }

        public virtual DbSet<Badge> Badges { get; set; }
        public virtual DbSet<BadgeRequirement> BadgeRequirements { get; set; }
        public virtual DbSet<Activity> Activities { get; set; }
        public virtual DbSet<ActivityType> ActivityTypes { get; set; }
        public virtual DbSet<ActivityRegistration> ActivityRegistrations { get; set; }
        public virtual DbSet<ActivityEquipment> ActivityEquipments { get; set; }
        public virtual DbSet<Equipment> Equipments { get; set; }
        public virtual DbSet<City> Cities { get; set; }
        public virtual DbSet<Troop> Troops { get; set; }
        public virtual DbSet<Member> Members { get; set; }
        public virtual DbSet<MemberBadge> MemberBadges { get; set; }
        public virtual DbSet<MemberBadgeProgress> MemberBadgeProgresses { get; set; }
        public virtual DbSet<Post> Posts { get; set; }
        public virtual DbSet<PostImage> PostImages { get; set; }
        public virtual DbSet<Comment> Comments { get; set; }
        public virtual DbSet<Like> Likes { get; set; }
        public virtual DbSet<Review> Reviews { get; set; }
        public virtual DbSet<Friendship> Friendships { get; set; }
        public virtual DbSet<Notification> Notifications { get; set; }
        public virtual DbSet<Document> Documents { get; set; }
        public virtual DbSet<Admin> Admins { get; set; }
        public virtual DbSet<User> Users { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // Badge
            modelBuilder.Entity<Badge>()
                .HasIndex(b => b.Name)
                .IsUnique();
            modelBuilder.Entity<Badge>()
                .HasMany(b => b.Requirements)
                .WithOne(br => br.Badge)
                .HasForeignKey(br => br.BadgeId)
                .OnDelete(DeleteBehavior.Cascade);      
            modelBuilder.Entity<Badge>()
                .HasMany(b => b.MemberBadges)
                .WithOne(mb => mb.Badge)
                .HasForeignKey(mb => mb.BadgeId)
                .OnDelete(DeleteBehavior.Cascade);

            // BadgeRequirement
            modelBuilder.Entity<BadgeRequirement>()
                .HasIndex(br => new { br.BadgeId, br.Description })
                .IsUnique();

            // ActivityType
            modelBuilder.Entity<ActivityType>()
                .HasIndex(at => at.Name)
                .IsUnique();
            modelBuilder.Entity<ActivityType>()
                .HasMany(at => at.Activities)
                .WithOne(a => a.ActivityType)
                .HasForeignKey(a => a.ActivityTypeId)
                .OnDelete(DeleteBehavior.Restrict);

            // Equipment
            modelBuilder.Entity<Equipment>()
                .HasIndex(e => e.Name)
                .IsUnique();
            modelBuilder.Entity<Equipment>()
                .HasMany(e => e.ActivityEquipments)
                .WithOne(ae => ae.Equipment)
                .HasForeignKey(ae => ae.EquipmentId)
                .OnDelete(DeleteBehavior.Cascade);

            // City
            modelBuilder.Entity<City>()
                .HasIndex(c => c.Name)
                .IsUnique();
            modelBuilder.Entity<City>()
                .HasMany(c => c.Troops)
                .WithOne(t => t.City)
                .HasForeignKey(t => t.CityId)
                .OnDelete(DeleteBehavior.Restrict);

            // Troop
            modelBuilder.Entity<Troop>()
                .HasIndex(t => t.Name)
                .IsUnique();
            modelBuilder.Entity<Troop>()
                .HasIndex(t => t.Email)
                .IsUnique();
            modelBuilder.Entity<Troop>()
                .HasIndex(t => t.Username)
                .IsUnique();
            modelBuilder.Entity<Troop>()
                .HasMany(t => t.Members)
                .WithOne(m => m.Troop)
                .HasForeignKey(m => m.TroopId)
                .OnDelete(DeleteBehavior.Restrict);
            modelBuilder.Entity<Troop>()
                .HasMany(t => t.Activities)
                .WithOne(a => a.Troop)
                .HasForeignKey(a => a.TroopId)
                .OnDelete(DeleteBehavior.Restrict);

            // Member
            modelBuilder.Entity<Member>()
                .HasIndex(m => m.Email)
                .IsUnique();
            modelBuilder.Entity<Member>()
                .HasIndex(m => m.Username)
                .IsUnique();

            // Admin
            modelBuilder.Entity<Admin>()
                .HasIndex(a => a.Email)
                .IsUnique();
            modelBuilder.Entity<Admin>()
                .HasIndex(a => a.Username)
                .IsUnique();
            modelBuilder.Entity<Admin>()
                .HasMany(a => a.Documents)
                .WithOne(d => d.Admin)
                .HasForeignKey(d => d.AdminId)
                .OnDelete(DeleteBehavior.Cascade);

            // Activity
            modelBuilder.Entity<Activity>()
                .HasMany(a => a.Registrations)
                .WithOne(ar => ar.Activity)
                .HasForeignKey(ar => ar.ActivityId)
                .OnDelete(DeleteBehavior.Cascade);
            modelBuilder.Entity<Activity>()
                .HasMany(a => a.EquipmentList)
                .WithOne(ae => ae.Activity)
                .HasForeignKey(ae => ae.ActivityId)
                .OnDelete(DeleteBehavior.Cascade);
            modelBuilder.Entity<Activity>()
                .HasMany(a => a.Posts)
                .WithOne(p => p.Activity)
                .HasForeignKey(p => p.ActivityId)
                .OnDelete(DeleteBehavior.Cascade);
            modelBuilder.Entity<Activity>()
                .HasMany(a => a.Reviews)
                .WithOne(r => r.Activity)
                .HasForeignKey(r => r.ActivityId)
                .OnDelete(DeleteBehavior.Cascade);
            modelBuilder.Entity<Activity>()
                .HasIndex(a => a.Title);

            // ActivityRegistration
            modelBuilder.Entity<ActivityRegistration>()
                .HasIndex(ar => new { ar.ActivityId, ar.MemberId })
                .IsUnique();
            modelBuilder.Entity<ActivityRegistration>()
                .HasOne(ar => ar.Member)
                .WithMany()
                .HasForeignKey(ar => ar.MemberId)
                .OnDelete(DeleteBehavior.NoAction);

            // ActivityEquipment
            modelBuilder.Entity<ActivityEquipment>()
                .HasIndex(ae => new { ae.ActivityId, ae.EquipmentId })
                .IsUnique();

            // MemberBadge
            modelBuilder.Entity<MemberBadge>()
                .HasIndex(mb => new { mb.MemberId, mb.BadgeId })
                .IsUnique();
            modelBuilder.Entity<MemberBadge>()
                .HasOne(mb => mb.Member)
                .WithMany()
                .HasForeignKey(mb => mb.MemberId)
                .OnDelete(DeleteBehavior.NoAction);

            // MemberBadgeProgress
            modelBuilder.Entity<MemberBadgeProgress>()
                .HasOne(mbp => mbp.Requirement)
                .WithMany()
                .HasForeignKey(mbp => mbp.RequirementId)
                .OnDelete(DeleteBehavior.NoAction);
            modelBuilder.Entity<MemberBadgeProgress>()
                .HasOne(mbp => mbp.MemberBadge)
                .WithMany()
                .HasForeignKey(mbp => mbp.MemberBadgeId)
                .OnDelete(DeleteBehavior.Cascade);
            modelBuilder.Entity<MemberBadgeProgress>()
                .HasIndex(mbp => new { mbp.MemberBadgeId, mbp.RequirementId })
                .IsUnique();

            // Post
            modelBuilder.Entity<Post>()
                .HasOne(p => p.CreatedBy)
                .WithMany()
                .HasForeignKey(p => p.CreatedById)
                .OnDelete(DeleteBehavior.Cascade);
            modelBuilder.Entity<Post>()
                .HasMany(p => p.Images)
                .WithOne(pi => pi.Post)
                .HasForeignKey(pi => pi.PostId)
                .OnDelete(DeleteBehavior.Cascade);
            modelBuilder.Entity<Post>()
                .HasMany(p => p.Comments)
                .WithOne(c => c.Post)
                .HasForeignKey(c => c.PostId)
                .OnDelete(DeleteBehavior.Cascade);
            modelBuilder.Entity<Post>()
                .HasMany(p => p.Likes)
                .WithOne(l => l.Post)
                .HasForeignKey(l => l.PostId)
                .OnDelete(DeleteBehavior.Cascade);
            modelBuilder.Entity<Post>()
                .HasIndex(p => p.CreatedAt);

            // PostImage
            modelBuilder.Entity<PostImage>()
                .HasIndex(pi => new { pi.PostId, pi.ImageUrl })
                .IsUnique();

            // Comment
            modelBuilder.Entity<Comment>()
                .HasIndex(c => new { c.PostId, c.MemberId, c.CreatedAt });
            modelBuilder.Entity<Comment>()
                .HasOne(c => c.Member)
                .WithMany()
                .HasForeignKey(c => c.MemberId)
                .OnDelete(DeleteBehavior.NoAction);

            // Like
            modelBuilder.Entity<Like>()
                .HasIndex(l => new { l.PostId, l.MemberId })
                .IsUnique();
            modelBuilder.Entity<Like>()
                .HasOne(l => l.Member)
                .WithMany()
                .HasForeignKey(l => l.MemberId)
                .OnDelete(DeleteBehavior.NoAction);

            // Review
            modelBuilder.Entity<Review>()
                .HasIndex(r => new { r.ActivityId, r.MemberId })
                .IsUnique();
            modelBuilder.Entity<Review>()
                .HasOne(r => r.Member)
                .WithMany(m => m.Reviews)
                .HasForeignKey(r => r.MemberId)
                .OnDelete(DeleteBehavior.NoAction);

            // Friendship
            modelBuilder.Entity<Friendship>()
                .HasOne(f => f.Requester)
                .WithMany()
                .HasForeignKey(f => f.RequesterId)
                .OnDelete(DeleteBehavior.Restrict);
            modelBuilder.Entity<Friendship>()
                .HasOne(f => f.Responder)
                .WithMany()
                .HasForeignKey(f => f.ResponderId)
                .OnDelete(DeleteBehavior.Restrict);
            modelBuilder.Entity<Friendship>()
                .HasIndex(f => new { f.RequesterId, f.ResponderId })
                .IsUnique();

            // Notification
            modelBuilder.Entity<Notification>()
                .HasIndex(n => n.CreatedAt);

            // Document
            modelBuilder.Entity<Document>()
                .HasIndex(d => d.Title);

            // User
            modelBuilder.Entity<User>()
                .HasMany(u => u.Posts)
                .WithOne(p => p.CreatedBy)
                .HasForeignKey(p => p.CreatedById)
                .OnDelete(DeleteBehavior.Cascade);
            modelBuilder.Entity<User>()
                .HasMany(u => u.Notifications)
                .WithOne(n => n.UserAccount)
                .HasForeignKey(n => n.UserAccountId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<User>().ToTable("Users");
            modelBuilder.Entity<Member>().ToTable("Members");
            modelBuilder.Entity<Troop>().ToTable("Troops");
            modelBuilder.Entity<Admin>().ToTable("Admins");
        }
    }
}